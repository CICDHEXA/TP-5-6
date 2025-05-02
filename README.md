# TP5-6

Gitlab: http://gitlab

Sonarqube: http://localhost:9001

Serveur web délivrant le json d'exemple: http://localhost:9050/result.json

Grafana: http://localhost:3000

## Prérequis

1. Installation du packet jq (sudo apt install jq -y) 
2. Création des mots de passe locaux avec ./random_gen_pass.sh
3. docker compose up -d et attendre le temps que Gitlab soit accessible via l'url(url à ajouté dans le /etc/hosts)
4. Utiliser le script init.sh et suivre les instructions
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

11. Acceder au serveur grafana: http://localhost:3000
12. Connexion avec les credentials par défaut (admin:admin)
13. Dans l'onglet dashboard, il y a normalement un dashboard nommé "Dashboard JSON"
14. Dans l'éditeur, il est possible de l'affiché en table "Table View" et de voir que le JSON a pu être récupéré
