#!/bin/bash

echo "CHECKING IF FILE EXISTS.."

if [[ -f ".env" ]]; then
	echo "THE FILE ALREADY EXISTS AND WON'T BE CREATED."
else 
	echo "CREATING THE FILE.."
	touch .env 


#GITLAB

	git_db_name=$(openssl rand -base64 10)
	git_db_username=$(openssl rand -base64 10)
	git_db_pass=$(openssl rand -base64 16)

	git_db_name=$(echo "$git_db_name" | tr -d "==")
	git_db_username=$(echo "$git_db_username" | tr -d "==")
	git_db_pass=$(echo "$git_db_pass" | tr -d "==")

	git_db_name=$(echo "$git_db_name" | tr -d "+")
	git_db_username=$(echo "$git_db_username" | tr -d "+")
	git_db_pass=$(echo "$git_db_pass" | tr -d "+")

	git_db_name=$(echo "$git_db_name" | tr -d "/")
	git_db_username=$(echo "$git_db_username" | tr -d "/")
	git_db_pass=$(echo "$git_db_pass" | tr -d "/")

	echo "#gitlab" >> .env
	echo "git_db_name=$git_db_name" >> .env
	echo "git_db_username=$git_db_username" >> .env
	echo "git_db_pass=$git_db_pass" >> .env



#SONAR

	SONAR_JDBC_user=$(openssl rand -base64 10)
	SONAR_JDBC_pass=$(openssl rand -base64 16)

	SONAR_JDBC_user=$(echo "$SONAR_JDBC_user" | tr -d "==")
	SONAR_JDBC_pass=$(echo "$SONAR_JDBC_pass" | tr -d "==")
	SONAR_JDBC_user=$(echo "$SONAR_JDBC_user" | tr -d "+")
	SONAR_JDBC_pass=$(echo "$SONAR_JDBC_pass" | tr -d "+")
	SONAR_JDBC_user=$(echo "$SONAR_JDBC_user" | tr -d "/")
	SONAR_JDBC_pass=$(echo "$SONAR_JDBC_pass" | tr -d "/")

	echo "#SONARQUBE" >> .env
	echo "SONAR_JDBC_pass=$SONAR_JDBC_pass" >> .env
	echo "SONAR_JDBC_user=$SONAR_JDBC_user" >> .env

#POSTGRES

	POSTGRES_DB_username=$(openssl rand -base64 10)
	POSTGRES_DB_pass=$(openssl rand -base64 16)
	POSTGRES_DB_name=$(openssl rand -base64 10)

	POSTGRES_DB_username=$(echo "$POSTGRES_DB_username" | tr -d "==")
	POSTGRES_DB_pass=$(echo "$POSTGRES_DB_pass" | tr -d "==")
	POSTGRES_DB_name=$(echo "$POSTGRES_DB_name" | tr -d "==")
	POSTGRES_DB_username=$(echo "$POSTGRES_DB_username" | tr -d "+")
	POSTGRES_DB_pass=$(echo "$POSTGRES_DB_pass" | tr -d "+")
	POSTGRES_DB_name=$(echo "$POSTGRES_DB_name" | tr -d "+")
	POSTGRES_DB_username=$(echo "$POSTGRES_DB_username" | tr -d "/")
	POSTGRES_DB_pass=$(echo "$POSTGRES_DB_pass" | tr -d "/")
	POSTGRES_DB_name=$(echo "$POSTGRES_DB_name" | tr -d "/")

	echo "#POSTGRES" >> .env
	echo "POSTGRES_DB_name=$POSTGRES_DB_name" >> .env
	echo "POSTGRES_DB_username=$POSTGRES_DB_username" >> .env
	echo "POSTGRES_DB_pass=$POSTGRES_DB_pass" >> .env


#OPENVAS

	OPENVAS_NAME=$(openssl rand -base64 10)
	OPENVAS_PASS=$(openssl rand -base64 16)

	OPENVAS_NAME=$(echo "$OPENVAS_NAME" | tr -d "==")
	OPENVAS_PASS=$(echo "$OPENVAS_PASS" | tr -d "==")
	OPENVAS_NAME=$(echo "$OPENVAS_NAME" | tr -d "+")
	OPENVAS_PASS=$(echo "$OPENVAS_PASS" | tr -d "+")
	OPENVAS_NAME=$(echo "$OPENVAS_NAME" | tr -d "/")
	OPENVAS_PASS=$(echo "$OPENVAS_PASS" | tr -d "/")


	echo "#OPENVAS" >> .env
	echo "OPENVAS_NAME=$OPENVAS_NAME" >> .env
	echo "OPENVAS_PASS=$OPENVAS_PASS" >> .env

#GRAFANA


fi

if [[ -f "custom.ini" ]]; then
	echo "THE FILE ALREADY EXISTS AND WON'T BE CREATED."
else 
	echo "CREATING THE FILE.."
	touch config.ini
    
	GRAFANA_NAME=$(openssl rand -base64 10)
	GRAFANA_PASS=$(openssl rand -base64 16)

	GRAFANA_NAME=$(echo "$GRAFANA_NAME" | tr -d "==")
	GRAFANA_PASS=$(echo "$GRAFANA_PASS" | tr -d "==")
	GRAFANA_NAME=$(echo "$GRAFANA_NAME" | tr -d "+")
	GRAFANA_PASS=$(echo "$GRAFANA_PASS" | tr -d "+")
	GRAFANA_NAME=$(echo "$GRAFANA_NAME" | tr -d "/")
	GRAFANA_PASS=$(echo "$GRAFANA_PASS" | tr -d "/")

	echo "admin_user=$GRAFANA_NAME" >> config.ini
	echo "admin_password=$GRAFANA_PASS" >> config.ini
fi