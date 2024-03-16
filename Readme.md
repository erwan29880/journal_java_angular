# journal blog privé

## technologies  

Pour le build de production il faut docker en mode non root (mode root non testé). La commande d'installation est un fichier bash, prévu pour systèmes unix.

Les fichiers de développements sont en Mysql8 pour la base de données, Java (spring boot, spring security) pour le serveur back-end, Angular pour le serveur front-end.     

## Installation  

Cloner le repository, autoriser les fichiers de configuration à l'exécution. Seul le fichier dev.sh installe des éléments (node modules).   
```bash
sudo chmod u+x *.sh
``` 

Lancer l'installation avec   
```bash
./install.sh
```
Le programme vous demandera :  
- le mot de passe souhaité pour Mysql  
- l'identifiant et le mot de passe souhaités pour Spring security    
- l'adresse souhaitée pour le serveur front-end    
- le port du serveur front-end (mettre 80 si le port n'est pas nécessaire)  

Le programme va effectuer des copies de sauvegarde des fichiers à changer pour le passage en production. Le fichier reinit.sh
```bash
./reinit.sh
``` 
permet de remplacer les fichiers de production par les fichiers de développement, et de supprimer les containers docker.  La base de données nécessaire au fonctionnement du programme est sauvegardée dans un fichier de sauvegarde sur demande, et sera réinstallée à la prochaine installation.

## maintenance  

Le fichier dev.sh permet d'installer et de lancer le serveur front-end pour le développement. Node, npm et Angular doivent être installés.    
Pour maintenir le serveur front-end :  
- le style est uniquement développé dans styles.scss  
- les composants sont dans les dossiers composants et erreur
- les services :
    - communication avec le back, gestions token JWT et sessionStorage  
    - authGuard  


Pour maintenir le serveur back-end il faut avoir java installé, et éventuellement maven : 
- le main est JournalApplication.java  
- le dossier control contient le controlleur Rest  
- le dossier database contient modèles, repo et service. 
- le dossier security protège les routes et gère le token JWT  


Les fichiers sauvegarde_bdd.sh et restaure_bdd.sh sont créés lors de l'installation. Il permettent : 
- de créer un crontab pour sauvegarde_bdd.sh (aucun crontab n'est installé par les scripts)  
- de restaurer la dernière sauvegarde de la base de données en cas de besoin  

Pour les utiliser il faut leur accorder les droits d'exécution.


