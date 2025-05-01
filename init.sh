#!/bin/bash
set -e

generate_password() {
  openssl rand -base64 16
}

# === Configuration ===
GITLAB_CONTAINER="gitlab"
ADMIN_USERNAME="gitadmin"
ADMIN_PASSWORD=$(generate_password)
ADMIN_EMAIL="${ADMIN_USERNAME}@example.com"
PROJECT_NAME="ScannerGITLAB"
GITLAB_URL="http://gitlab"

# === Liste de capitales ===
CAPITALES=("Paris" "Berlin" "Rome" "Madrid" "Vienna" "Ottawa" "Tokyo" "Canberra" "Brasilia" "Oslo")
USED_USERS=()
DEV_USERS=()

get_random_capital() {
  while true; do
    CAPITAL="${CAPITALES[$RANDOM % ${#CAPITALES[@]}]}"
    if [[ ! " ${USED_USERS[*]} " =~ " ${CAPITAL} " ]]; then
      USED_USERS+=("$CAPITAL")
      echo "$CAPITAL"
      return
    fi
  done
}

# === Création du compte admin ===
echo "[INFO] Creating admin user and generating token..."

ADMIN_TOKEN=$(docker exec -i \
  -e USERNAME="$ADMIN_USERNAME" \
  -e PASSWORD="$ADMIN_PASSWORD" \
  -e EMAIL="$ADMIN_EMAIL" \
  "$GITLAB_CONTAINER" gitlab-rails runner - <<'RUBY'
username = ENV['USERNAME']
password = ENV['PASSWORD']
email    = ENV['EMAIL']

org = defined?(Organizations::Organization) ? Organizations::Organization.first : nil
raise "No organization found" if org.nil?

user = User.find_by(username: username)
unless user
  response = Users::CreateService.new(nil, {
    username: username,
    name: username,
    email: email,
    password: password,
    password_confirmation: password,
    skip_confirmation: true
  }).execute
  user = response.payload[:user]
  ns = Namespace.new(name: username, path: username, owner: user, organization: org)
  ns.save!
  user.namespace = ns
  user.save!
  user.update!(admin: true)
end

token = user.personal_access_tokens.create!(
  scopes: [:api],
  name: "automation token #{Time.now.to_i}",
  expires_at: 1.year.from_now
)
puts token.token
RUBY
)

ADMIN_TOKEN=$(echo "$ADMIN_TOKEN" | tail -n 1)

# === Création du projet GitLab ===
echo "[INFO] Creating GitLab project '$PROJECT_NAME'..."
PROJECT_RESPONSE=$(curl -sS --header "PRIVATE-TOKEN: $ADMIN_TOKEN" \
  --data "name=$PROJECT_NAME&visibility=private&initialize_with_readme=true" \
  "$GITLAB_URL/api/v4/projects")

PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.id')

if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
  echo "[ERROR] Could not retrieve project ID"
  echo "$PROJECT_RESPONSE"
  exit 1
fi

# === Création des comptes développeurs ===
ACCOUNT_INFO=()
echo "[INFO] Creating 2 developer users..."

for i in 1 2; do
  DEV_USERNAME=$(get_random_capital)
  DEV_EMAIL="$(echo "$DEV_USERNAME" | tr '[:upper:]' '[:lower:]')@example.com"
  DEV_PASSWORD=$(generate_password)

  echo "[INFO] Creating user $DEV_USERNAME..."

  DEV_TOKEN=$(docker exec -i \
    -e USERNAME="$DEV_USERNAME" \
    -e PASSWORD="$DEV_PASSWORD" \
    -e EMAIL="$DEV_EMAIL" \
    "$GITLAB_CONTAINER" gitlab-rails runner - <<'RUBY'
username = ENV['USERNAME']
password = ENV['PASSWORD']
email    = ENV['EMAIL']

org = defined?(Organizations::Organization) ? Organizations::Organization.first : nil
raise "No organization found" if org.nil?

user = User.find_by(username: username)
unless user
  response = Users::CreateService.new(nil, {
    username: username,
    name: username,
    email: email,
    password: password,
    password_confirmation: password,
    skip_confirmation: true
  }).execute
  user = response.payload[:user]
  ns = Namespace.new(name: username, path: username, owner: user, organization: org)
  ns.save!
  user.namespace = ns
  user.save!
end

token = user.personal_access_tokens.create!(
  scopes: [:api],
  name: "dev token #{Time.now.to_i}",
  expires_at: 1.year.from_now
)
puts token.token
RUBY
  )

  DEV_TOKEN=$(echo "$DEV_TOKEN" | tail -n 1)

  USER_ID=$(curl -sS --header "PRIVATE-TOKEN: $ADMIN_TOKEN" "$GITLAB_URL/api/v4/users?username=$DEV_USERNAME" | jq -r '.[0].id')

  curl -sS --header "PRIVATE-TOKEN: $ADMIN_TOKEN" \
    --data "user_id=$USER_ID&access_level=30" \
    "$GITLAB_URL/api/v4/projects/$PROJECT_ID/members"

  curl -sS --header "PRIVATE-TOKEN: $ADMIN_TOKEN" \
    --data "title=Task for $DEV_USERNAME&assignee_ids[]=$USER_ID&description=Auto-assigned issue" \
    "$GITLAB_URL/api/v4/projects/$PROJECT_ID/issues" > /dev/null

  ACCOUNT_INFO+=("$DEV_USERNAME|$DEV_PASSWORD|$DEV_TOKEN|false")
done

ACCOUNT_INFO+=("$ADMIN_USERNAME|$ADMIN_PASSWORD|$ADMIN_TOKEN|true")

# === Runner GitLab ===
echo -e "\n[INFO] Preparing to register GitLab runner..."
echo -e "\n[INSTRUCTION] Connectez-vous à l'interface GitLab avec les identifiants suivants :"
echo "  URL       : http://gitlab"
echo "  Username  : $ADMIN_USERNAME"
echo "  Password  : $ADMIN_PASSWORD"
echo -e "\nEnsuite :"
echo "  1. Rendez-vous sur : http://gitlab/admin/runners/new"
echo "  2. Cochez la case : 'Run untagged jobs'"
echo "  3. Copiez la commande affichée dans la section 'Step 1'"
echo -e "  4. Laissez ce script ouvert pour continuer automatiquement.\n"

read -p "[ACTION REQUISE] Collez ici la commande affichée (ex: gitlab-runner register --non-interactive ...): " RUNNER_COMMAND

echo "[INFO] Enregistrement du runner dans le conteneur 'gitlab-runner'..."
docker exec gitlab-runner bash -c "$RUNNER_COMMAND --non-interactive --executor docker --docker-image alpine"

echo "[INFO] Attente de la confirmation de l'enregistrement du runner..."
sleep 5

echo -e "\n[INFO] Runner ajouté. Vérifiez la section des 'runners' pour les détails : http://gitlab/admin/runners"

# === Ajout du network docker ===
echo -e "\n[INFO] Ajout du réseau 'tp-5-6_gitlabnet' dans la configuration du runner"
sed -i '/^\s*network_mtu = 0\s*$/a \ \ \ \ network_mode = "tp-5-6_gitlabnet"' runner/config.toml

# === Préparer le code Python depuis le template ===
echo "[INFO] Preparing Python script from template..."
rm -rf "$PROJECT_NAME"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

cp ../main.py main.py
cp ../.gitlab-ci.yml .gitlab-ci.yml
sed -i "s|{REPLACEACCESSTOKEN}|\"$ADMIN_TOKEN\"|g" main.py
sed -i "s|{REPLACEPROJECTID}|$PROJECT_ID|g" main.py

git init
git checkout -b develop
git config user.email "$ADMIN_EMAIL"
git config user.name "$ADMIN_USERNAME"
git add -A
git commit -m "feat: Auto adding project"
REPO_URL_WITH_AUTH="http://oauth2:$ADMIN_TOKEN@${GITLAB_URL#http://}/$ADMIN_USERNAME/$PROJECT_NAME.git"
git remote add origin "$REPO_URL_WITH_AUTH"
git push -u origin develop

# === Résumé final ===
echo -e "\n[INFO] Summary of all accounts:"
printf "\n%-15s | %-20s | %-30s | %-5s\n" "USERNAME" "PASSWORD" "ACCESS TOKEN" "ADMIN"
printf -- "-----------------+----------------------+--------------------------------+-------\n"
for entry in "${ACCOUNT_INFO[@]}"; do
  IFS='|' read -r user pass token isadmin <<< "$entry"
  printf "%-15s | %-20s | %-30s | %-5s\n" "$user" "$pass" "$token" "$isadmin"
done

# === Merge develop -> main (en tenant compte du README déjà présent) ===
echo "[INFO] Merging 'develop' into 'main'..."
git fetch origin main
git checkout -b main origin/main
git merge develop --no-edit --allow-unrelated-histories
git push -u origin main

# === Résumé final ===
echo -e "\n[INFO] Summary of all accounts:"
printf "\n%-15s | %-20s | %-30s | %-5s\n" "USERNAME" "PASSWORD" "ACCESS TOKEN" "ADMIN"
printf -- "-----------------+----------------------+--------------------------------+-------\n"
for entry in "${ACCOUNT_INFO[@]}"; do
  IFS='|' read -r user pass token isadmin <<< "$entry"
  printf "%-15s | %-20s | %-30s | %-5s\n" "$user" "$pass" "$token" "$isadmin"
done

echo -e "\n[DONE] Project is available at: $GITLAB_URL/$ADMIN_USERNAME/$PROJECT_NAME (branch: main)"
