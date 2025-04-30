# TP5-6

Gitlab: http://gitlab

Sonarqube: http://localhost:9001

## Prérequis

1. docker compose up -d et attendre le temps que Gitlab soit accessible via l'url(url ajouté dans le /etc/hosts)
2. Utiliser le script init.sh et suivre les instructions
3. Modification du fichier runner/config.toml en rajoutant 'network_mode = "tp-5-6_gitlabnet"' dans l'onglet [runners.docker]
4. Connexion à Sonarqube(http://localhost:9001/) avec les credentials par défault (admin:admin) et modification du mot de passe administrateur
5. Cliquer sur 'Add a project' puis 'From Gitlab'
6. Renseigner les informations suivantes: 
    - Configuration name: Gitlab
    - GitLab API URL: http://gitlab/api/v4
    - Personal Access Token: ACCESS TOKEN du compte administrateur affiché dans le tableau final
7. Re-renseigner l'ACCESS TOKEN
8. Set-up le projet "ScannerGITLAB" et suivre les instructions de sonarqube pour ajouter avoir l'analyse:
    - SONAR_HOST_URL: http://sonarqube:9000


En cas de problème au reboot, il faut executer reboot.sh