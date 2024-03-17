#!/bin/bash

NODEMODULES="$PWD/front/node_modules"
EXTENSION="old"
PAT="$PWD"
PROPERTIES="$PAT/back/src/main/resources/application.properties"
PROPERTIES_SAUV="$PROPERTIES$EXTENSION"
CONTROLLEUR="$PAT/back/src/main/java/fr/erwan/journal/journal/control/Controlleur.java"
CONTROLLEUR_SAUV="$CONTROLLEUR$EXTENSION"
UPAF="$PAT/back/src/main/java/fr/erwan/journal/journal/security/UsernamePasswordAuthFilter.java"
UPAF_SAUV="$UPAF$EXTENSION"
COMPOSE="$PAT/docker-compose-sql.yml"
COMPOSE_SAUV="$COMPOSE$EXTENSION"
COMPOSE_SERVEURS="$PAT/docker-compose-serveurs.yml"
COMPOSE_SERVEURS_SAUV="$COMPOSE_SERVEURS$EXTENSION"
SERVICE="$PAT/front/src/app/services/service.service.ts"
SERVICE_SAUV="$PAT/front/src/app/services/service.service.ts$EXTENSION"
dockerfile_sql="$PAT/database/Dockerfile"
dockerfile_sql_sauv="$dockerfile_sql$EXTENSION"

arr=("$PROPERTIES" "$CONTROLLEUR" "$UPAF" "$COMPOSE" "$SERVICE" "$COMPOSE_SERVEURS" "$dockerfile_sql")
arr_sauv=("$PROPERTIES_SAUV" "$CONTROLLEUR_SAUV" "$UPAF_SAUV" "$COMPOSE_SAUV" "$SERVICE_SAUV" "$COMPOSE_SERVEURS_SAUV" "$dockerfile_sql_sauv")

echo "tentative de restauration"

for (( i=0; i<${#arr_sauv[@]}; i++ ))
    do
        if [ -f "${arr_sauv[$i]}" ]
            then mv "${arr_sauv[$i]}" "${arr[$i]}"
        fi
done

echo "restauration effectuée, suppression des fichiers de sauvegarde si besoin"

for t in ${arr_sauv[@]} 
    do
        if [ -f "$t" ]
            then
                rm "$t"
        fi
done

docker exec journaldb bash -c "mysqldump -u root -pmonpwdsql --databases application > journal.sql"
rm "$PAT"/database/sql_restaure.sql
echo "Souhaitez-vous sauvegarder la base de données ? o/n"
read reponse
if [ "$reponse" == "o" ]
    then 
docker exec journaldb bash -c "mysqldump -u root -pmonpwdsql --databases application > journal.sql"
    docker cp journaldb:journal.sql "$PAT"/database/sql_restaure.sql
fi

# suppression du container de la base de données
docker-compose -f "$COMPOSE_SERVEURS" down
docker-compose -f "$COMPOSE" down