#!/bin/bash

# todo : donner la possibilité de changer les ports
# todo : entrée utilisateur

# utilitaires
EXTENSION="old"
PAT="$PWD"
COMPOSE_PASSWORD_LINE="MYSQL_ROOT_PASSWORD"
egal="="
port_back="8999"
port_prod="5678"

##############################################################################################
##############################################################################################
####  renseigner ici vos identifiants souhaités  #############################################
login_prod="monlogindeprod"
pwd_prod="monpwddeprod"
pwd_sql_prod_entry="sqlpassword"
host_du_front_end="http:\/\/localhost" 
##############################################################################################
##############################################################################################
##############################################################################################

# paths---------------------------------------------------

# front
NODEMODULES="$PWD/front/node_modules"
ANGULAR_BUILT="$PWD/front/dist"
NODE_BUILD_DEV="$ANGULAR_BUILT/journal"
NODE_BUILD_PROD="$PWD/frontprod/build"
REQUEST_URL="http:/\/\localhost:8080"
SERVICE="$PAT/front/src/app/services/service.service.ts"
SERVICE_SAUV="$PAT/front/src/app/services/service.service.ts$EXTENSION"


# back
PROPERTIES="$PAT/back/src/main/resources/application.properties"
PROPERTIES_SAUV="$PROPERTIES$EXTENSION"
CONTROLLEUR="$PAT/back/src/main/java/fr/erwan/journal/journal/control/Controlleur.java"
CONTROLLEUR_SAUV="$CONTROLLEUR$EXTENSION"
UPAF="$PAT/back/src/main/java/fr/erwan/journal/journal/security/UsernamePasswordAuthFilter.java"
UPAF_SAUV="$UPAF$EXTENSION"

# docker
COMPOSE="$PAT/docker-compose-sql.yml"
COMPOSE_SAUV="$COMPOSE$EXTENSION"
COMPOSE_SERVEURS="$PAT/docker-compose-serveurs.yml"
COMPOSE_SERVEURS_SAUV="$COMPOSE_SERVEURS$EXTENSION"
COMPOSE_VOLUME="$PAT/database/mysqld"
JAR_BUILT="$PAT/back/target/journal-prod.jar"
docker_network="journal"
database_sauv="$PAT/journalsauv.sql"

# éléments à remplacer dans les fichiers
login_dev="superman"
pwd_dev="supergirl"
pwd_sql_dev="=pa"
pwd_sql_prod="$egal$pwd_sql_prod_entry"
sql_url_dev="localhost"
sql_url_prod="journaldb"
host_dev="http:\/\/localhost:4200"
compose_password_line_dev="$COMPOSE_PASSWORD_LINE$pwd_sql_dev"
compose_password_line_prod="$COMPOSE_PASSWORD_LINE$pwd_sql_prod"
host_prod="$host_du_front_end:$port_prod"
host_prod_back="http:\/\/localhost:$port_back"

arr=("$PROPERTIES" "$CONTROLLEUR" "$UPAF" "$COMPOSE" "$SERVICE" "$COMPOSE_SERVEURS")
arr_sauv=("$PROPERTIES_SAUV" "$CONTROLLEUR_SAUV" "$UPAF_SAUV" "$COMPOSE_SAUV" "$SERVICE_SAUV" "$COMPOSE_SERVEURS_SAUV")


function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
    printf "\r [${_fill// /#}${_empty// /-}]"
}

echo "------------------------------------------------"
echo "----traitement des fichiers et remplacements----"
echo " "

for t in ${arr[@]} 
    do
        if [ ! -f "$t" ]
            then
                echo "le fichier $t n'existe pas"
                exit 1;
        fi
done

echo "les fichiers à modifier existent, sauvegarde des fichiers de dev"

for (( i=0; i<${#arr_sauv[@]}; i++ ))
    do
        if [ ! -f "${arr_sauv[$i]}" ]
            then cp "${arr[$i]}" "${arr_sauv[$i]}"
        fi
done


echo "modification des fichiers de dev par prod"

sed -i 's/'$login_dev'/'$login_prod'/' "$PROPERTIES"
sed -i 's/'$pwd_dev'/'$pwd_prod'/' "$PROPERTIES"
sed -i 's/'$sql_url_dev'/'$sql_url_prod'/' "$PROPERTIES"
sed -i 's/'$pwd_sql_dev'/'$pwd_sql_prod'/' "$PROPERTIES"
sed -i 's|'$host_dev'|'$host_prod'|' "$CONTROLLEUR"
sed -i 's/'$login_dev'/'$login_prod'/' "$UPAF"
sed -i 's/'$compose_password_line_dev'/'$compose_password_line_prod'/' "$COMPOSE"
sed -i 's/9000/'$port_prod'/' "$COMPOSE_SERVEURS"
sed -i 's|'$REQUEST_URL'|'$host_prod_back'|' "$SERVICE"

# suppression des lignes d'ouverture de ports pour la base de données
sed -i '12d' "$COMPOSE"
sed -i '11d' "$COMPOSE"


# copier le mot de passe sql dans reinit pour pouvoir exporter la bdd et la réinitialiser à l'installation
sed -i '/passwordinit/d' reinit.sh
sed -i '/journalsauv/i\docker exec journaldb bash -c "mysqldump -u root -p$passwordinit application journal > journal.sql"' reinit.sh
sed -i.bak '/modules/i\passwordinit="'$pwd_sql_prod_entry'"' reinit.sh

# changer le fichier de configuration sql si il y a une restauration de table journal à effectuer 
if [ -f "$database_sauv" ]
    then 
        sed -i 's/sql.sql/sql_restaure.sql/' "$PAT/database/Dockerfile"
fi

echo " "
echo "---------------------------------------------------------"
echo "----installation des paquets requis pour le front-end----"
echo " "

# vérification qu'angular est installé
angular_global=$(npm list --global | grep @angular\/cli)
if [ "${#angular_global[0]}" -gt 0 ]
    then 
        echo "angular cli déjà installée globalement"
    else 
        echo "installation de angular cli globalement"
        npm install -g @angular/cli
fi

# installation des paquets requis
if [ ! -d "$NODEMODULES" ]
    then
        echo "Installation des packages node";
        cd front && npm install && cd ..
        echo "angular done\n" 
    else 
        echo "le dossier node_modules existe, skipping"
fi


if [  -d "$NODE_BUILD_DEV" ]
    then 
        echo "suppression de $NODE_BUILD_DEV"
        rm -r "$ANGULAR_BUILT"
        echo "done"
fi 

if [  -d "$NODE_BUILD_PROD" ]
    then 
        echo "suppression de $NODE_BUILD_PROD"
        rm -r "$NODE_BUILD_PROD"
        echo "done"
fi 


echo " "
echo "-----------------------"
echo "----build d'angular----"
echo " "

cd front && ng build && cd ..
cp -r "$NODE_BUILD_DEV" "$NODE_BUILD_PROD"
rm -r "$ANGULAR_BUILT"


echo " "
echo "------------------------------------------"
echo "----installation de la base de données----"
echo " "


docker_networks=$(docker network ls | grep journal)
if [ "${#docker_networks[0]}" -gt 0 ]
    then 
        echo "le réseau docker existe"
    else 
        echo "création du réseau docker"
        docker network create journal
fi

docker-compose -f "$COMPOSE" up -d --build


echo " "
echo "-----------------------"
echo "----build de spring----"
echo " "

if [ -f "$JAR_BUILT" ]
    then 
        rm "JAR_BUILT"
fi

cd back && mvn install -DskipTests
cd ..
mv "$JAR_BUILT" backprod


echo " "
echo "--------------------------------------"
echo "----build des serveurs avec docker----"
echo " "

docker-compose -f "$COMPOSE_SERVEURS" up -d --build

# attendre un instant que le serveur et la base de données puissent communiquer, et restaurer la table si besoin
_start=1
_end=20
for number in $(seq ${_start} ${_end})
do
    sleep 0.2
    ProgressBar ${number} ${_end}
done

if [ -f "$database_sauv" ]
    then 
        echo " "
        docker ps | grep journaldb
        docker cp "$database_sauv" journaldb:journal.sql
        docker exec journaldb bash -c "mysql -u root -p$pwd_sql_prod_entry application < journal.sql"
fi

# echo "Verifier que l'application web fonctionne, aller sur :"
# echo "$host_prod"
# echo "souhaitez-vous effacer les fichiers de développement ? o/n"
# read res

# if [ "$res" == "o" ]
#     then 
#         echo "effacement des dossiers inutiles..."
#         rm -r back 
#         rm -r front 
#         rm -r "$COMPOSE_SAUV"
#         rm -r "$COMPOSE_SERVEURS_SAUV"
#         echo "done"
# fi