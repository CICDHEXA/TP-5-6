#!/bin/bash
set -e

# === Configuration ===
GITLAB_CONTAINER="gitlab"
USERNAME="gitadmin"
PASSWORD="MotDePasseSecurise123!"
EMAIL="${USERNAME}@example.com"
PROJECT_NAME="hello-world"
GITLAB_URL="http://gitlab"

echo "[INFO] Creating user and generating token..."

# === Ruby script for create ADMIN USER ===
ACCESS_TOKEN=$(docker exec -i \
  -e USERNAME="$USERNAME" \
  -e PASSWORD="$PASSWORD" \
  -e EMAIL="$EMAIL" \
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

ACCESS_TOKEN=$(echo "$ACCESS_TOKEN" | tail -n 1)
echo "[INFO] Token stored in variable: $ACCESS_TOKEN"

# === Create project
echo "[INFO] Creating GitLab project '$PROJECT_NAME'..."
PROJECT_RESPONSE=$(curl -sS --header "PRIVATE-TOKEN: $ACCESS_TOKEN" \
  --data "name=$PROJECT_NAME&visibility=private&initialize_with_readme=true" \
  "$GITLAB_URL/api/v4/projects")

PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.id')

if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
  echo "[ERROR] Could not retrieve project ID"
  echo "$PROJECT_RESPONSE"
  exit 1
fi

# === Remove protection on main branch
echo "[INFO] Removing protection on 'main' branch..."
curl -sS --request DELETE \
  --header "PRIVATE-TOKEN: $ACCESS_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID/protected_branches/main" > /dev/null || true

# === Push Python script
echo "[INFO] Pushing hello world Python script..."

rm -rf "$PROJECT_NAME"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"
echo 'print("Hello, world!")' > hello.py

git init
git checkout -b main
git config user.email "$EMAIL"
git config user.name "$USERNAME"
git add hello.py
git commit -m "feat: hello world script"

REPO_URL_WITH_AUTH="http://oauth2:$ACCESS_TOKEN@${GITLAB_URL#http://}/$USERNAME/$PROJECT_NAME.git"
git remote add origin "$REPO_URL_WITH_AUTH"
git push -u origin main --force

echo "[DONE] Project is available at: $GITLAB_URL/$USERNAME/$PROJECT_NAME"