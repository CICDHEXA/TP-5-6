# TP5-6

Gitlab: http://gitlab

Sonarqube: http://localhost:9001

## Prérequis

1. Création des mots de passe locaux avec ./random_gen_pass.sh
2. docker compose up -d et attendre le temps que Gitlab soit accessible via l'url(url à ajouté dans le /etc/hosts)
3. Utiliser le script init.sh et suivre les instructions
4. Modification du fichier runner/config.toml en rajoutant 'network_mode = "tp-5-6_gitlabnet"' dans l'onglet [runners.docker]
5. Connexion à Sonarqube(http://localhost:9001/) avec les credentials par défault (admin:admin) et modification du mot de passe administrateur
6. Cliquer sur 'Add a project' puis 'From Gitlab'
7. Renseigner les informations suivantes: 
    - Configuration name: Gitlab
    - GitLab API URL: http://gitlab/api/v4
    - Personal Access Token: ACCESS TOKEN du compte administrateur affiché dans le tableau final
8. Re-renseigner l'ACCESS TOKEN
9. Set-up le projet "ScannerGITLAB" et suivre les instructions de sonarqube pour avoir l'analyse:
    - SONAR_HOST_URL: http://sonarqube:9000
    - il faut rajouter la branch develop dans le code 'only' du .gitlab-ci.yaml

En cas de problème au reboot, il faut executer reboot.sh