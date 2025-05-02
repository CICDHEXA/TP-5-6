# TP5-6

Gitlab: http://gitlab

Sonarqube: http://localhost:9001

## Prérequis

Installation de jq

1. Création des mots de passe locaux avec ./random_gen_pass.sh
2. docker compose up -d et attendre le temps que Gitlab soit accessible via l'url(url à ajouté dans le /etc/hosts)
3. Utiliser le script init.sh et suivre les instructions
5. Connexion à Sonarqube(http://localhost:9001/) avec les credentials par défault (admin:admin) et modification du mot de passe administrateur
6. Cliquer sur 'Add a project' puis 'From Gitlab'
7. Renseigner les informations suivantes: 
    - Configuration name: Gitlab
    - GitLab API URL: http://gitlab/api/v4
    - Personal Access Token: ACCESS TOKEN du compte administrateur affiché dans le tableau final
8. Re-renseigner l'ACCESS TOKEN
9. Set-up le projet "ScannerGITLAB" et suivre les instructions de sonarqube pour avoir l'analyse:
    - SONAR_HOST_URL: http://sonarqube:9000
10. Relancer la pipeline pour appliquer les dernières modifications de secrets et ainsi avoir l'analyse sur sonarqube

En cas de problème au reboot, il faut executer reboot.sh

Il y a un problème dans l'ajout d'artefact donc pour simuler le rendu sur grafana j'ai rajouté un serveur nginx distribuant un json type rendu par l'exécution du code python.

