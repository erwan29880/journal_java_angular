#!/bin/bash

docker-compose -f docker-compose-sql.yml up -d 

NODEMODULES="$PWD/front/node_modules"
ANGULAR_BUILT="$PWD/front/dist"
NODE_BUILD_DEV="$ANGULAR_BUILT/journal"
NODE_BUILD_PROD="$PWD/frontprod/build"
NODEMODULES="$PWD/front/node_modules"
ANGULAR_BUILT="$PWD/front/dist"
NODE_BUILD_DEV="$ANGULAR_BUILT/journal"
NODE_BUILD_PROD="$PWD/frontprod/build"

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

echo "Serveur de développement front-end http:\/\/localhost:4200"
echo "Vous pouvez démarrer le serveur java en exécutant la class main back\/src\/main\/java\/fr\/erwan\/journal\/journal\/JournalApplication.java"
echo "Serveur de développement back-end http:\/\/localhost:8080"
echo "Note : java, node et npm doivent être installés sur votre ordinateur"

cd front && ng serve




