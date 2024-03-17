#!/bin/bash

if [ -f docker-compose-serveurs.ymlold ]
    then 
        echo "Utiliser la reinit.sh avant de réinstaller ! "
        exit 1
fi


IN="$(whereis -b docker-compose)"
IN2="$(whereis -b "docker compose")"
fichiers="$(grep -R -l "docker-compose " ./*)"
pattern="docker-compose "
replacement="docker compose "

IFS=':'; arrIN=($IN); unset IFS;
IFS=':'; arrIN2=($IN2); unset IFS;


if [ "${arrIN[1]}" == "" ] && [ "${arrIN2[1]}" == "" ] 
    then 
        echo "Vous devez installer docker-compose pour utiliser le programme !"
        exit
    else 
        echo "docker-compose est installé, vérification entre docker-compose ou docker compose"
fi

# si il n'y a pas la commande docker-compose, remplacement conditionnel de docker-compose par docker compose
if [ "${arrIN[1]}" == "" ]
then
    # parcourir les fichiers dans lesquels il y a le pattern docker-compose
    for output in $fichiers
        do
            # recherche de la ligne avec docker-compose dans chaque fichier au format n°ligne:la ligne
            lignes=$(grep -n docker-compose "$output")

            # séparation en lignes
            echo "$lignes" | while IFS= read -r line; do
                IFS=':'; arrIN=($line); unset IFS;
                
                # affectation du numéro au format string dans prov
                to_int="${arrIN[0]}"
                
                # parseInt
                numero_ligne=$(echo "$to_int + 0" | bc)
                
                # condition de remplacement
                    if [ "$numero_ligne" -gt 238 ] && [ "$output" == "./install.sh" ]
                        then
                            sed -i "${numero_ligne}s/${pattern}/${replacement}/" "$output"
                    fi
                    if [ ! "$output" == "./install.sh" ]
                        then 
                            sed -i "${numero_ligne}s/${pattern}/${replacement}/" "$output"
                    fi
                done
    done
fi


# utilitaires
EXTENSION="old"
egal="="
PAT="$PWD"
COMPOSE_PASSWORD_LINE="MYSQL_ROOT_PASSWORD"
port_back="8999"

##############################################################################################
##############################################################################################
####  renseigner ici vos identifiants souhaités  #############################################
echo "Rentrez le mot de passe souhaité pour la base de données (pas de caractères spéciaux ni d'espaces) :"
read pwd_sql_prod_entry
echo "Rentrez le login souhaité pour Spring Security :"
read login_prod
echo "Rentrez le mot de passe souhaité pour Spring Security (pas de caractères spéciaux ni d'espaces) :"
read pwd_prod
echo "Rentrez l'url souhaitée pour le front-end (sans le port) :"
read host_du_front_end
echo "Rentrez le port pour l'url (mettez 80 si le port n'est pas nécessaire). Ne pas utiliser le port 8999 réservé au serveur back-end :"
read port_prod


# en cas de donnée(s) vides
if [ "$pwd_sql_prod_entry" == "" ]
    then 
        pwd_sql_prod_entry="monpwdsql"
fi
if [ "$login_prod" == "" ]
    then 
        login_prod="monloginspring"
fi
if [ "$pwd_prod" == "" ]
    then 
        pwd_prod="monpwdspring"
fi
if [ "$host_du_front_end" == "" ]
    then 
        host_du_front_end="http://localhost"
fi
if [ "$port_prod" == "" ]
    then 
        port_prod="80"
fi



##############################################################################################
##############################################################################################
##############################################################################################

# paths---------------------------------------------------

# front
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
database_sauv="$PAT/database/sql_restaure.sql"

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
dockerfile_sql="$PAT/database/Dockerfile"
dockerfile_sql_sauv="$dockerfile_sql$EXTENSION"


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


# --------------------------- bdd
echo "voulez-vous repartir avec une base de données vide ? o/n"
read bddvide

if [ "$bddvide" == "o" ]
    then 
        truncate -s 0 "$database_sauv"
fi
if [ ! -f "$database_sauv" ]
    then 
        touch "$database_sauv"
fi


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
sed -i '/docker exec journaldb/d' reinit.sh
sed -i '/sql_restaure/i\docker exec journaldb bash -c "mysqldump -u root -p'$pwd_sql_prod_entry' --databases application > journal.sql"' reinit.sh

# changer le fichier de configuration sql si il y a une restauration de table journal à effectuer 
cp "$dockerfile_sql" "$dockerfile_sql_sauv"
if [ -f "$database_sauv" ]
    then 
        test_sql_restaure=$(cat "$PAT"/database/sql_restaure.sql | grep application)
        if [ ! -s "$PAT"/database/sql_restaure.sql ]
            then 
                echo "le fichier de sauvegarse sql ne peut pas être utilisé"
            else 
                sed -i 's/sql.sql/sql_restaure.sql/' "$PAT/database/Dockerfile"
        fi
fi


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

echo " "

# création des fichiers de sauvegarde et de restauration de la bdd pour crontab
truncate -s 0 sauvegarde_bdd.sh
printf '#!/bin/bash\n' > sauvegarde_bdd.sh
echo "docker exec journaldb bash -c \"mysqldump -u root -p"$pwd_sql_prod_entry" --databases application > application.sql\"" >> sauvegarde_bdd.sh
echo docker cp journaldb:application.sql "$PAT"/db_backup.sql >> sauvegarde_bdd.sh

truncate -s 0 restaure_bdd.sh 
printf '#!/bin/bash\n' > restaure_bdd.sh
echo docker cp "$PAT"/db_backup.sql journaldb:application.sql >> restaure_bdd.sh
echo "docker exec journaldb bash -c \"mysql -u root -p"$pwd_sql_prod_entry" < application.sql\"" >> restaure_bdd.sh


echo "Verifier que l'application web fonctionne, aller sur :"
echo "$host_prod"
echo "souhaitez-vous effacer les fichiers non indispensables pour le build ? o/n"
read res

if [ "$res" == "o" ]
    then 
        echo "effacement des dossiers inutiles..."
        if [ -d "$PAT"/front/node_modules ]
            then rm -r "$PAT"/front/node_modules
        fi
        if [ -d "$PAT"/frontprod/node_modules ]
            then rm -r "$PAT"/frontprod/node_modules
        fi 
        if [ -d "$PAT"/back/target ]
            then rm -r "$PAT"/back/target
        fi
        echo "done"
fi

echo "Vous pouvez effectuer des sauvegardes régulières de la base de données par crontab avec le fichier sauvegarde_bdd.sh"
echo "Vous pouvez alors si besoin effectuer une restauration avec le fichier restaure_bdd.sh"