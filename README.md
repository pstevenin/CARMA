# CARMA (CARtographie des MAtériels)
Outil de visualisation géographique des âges moyens des équipements haute tension de RTE.

### Installation et lancement
* Cloner le dépôt Github à partir de RStudio en cliquant sur File / New Project / Version Control / Git.
* Lancer l'application depuis RStudio en ouvrant le fichier **global.R** et en cliquant sur le bouton **Run App**.
* Liste des librairies utilisées par l'application qu'il est nécessaire d'installer :
  + dplyr
  + DT
  + leaflet
  + leafpop
  + mapview
  + RColorBrewer
  + readxl
  + sf
  + shiny
  + shinydashboard
  + shinyWidgets

### Utilisation
* Avant toute utilisation, disposer d'un répertoire de données d'entrées composé des éléments suivants :
  + 1 fichier csv de correspondance de noms par catégorie de localisation (GMR / GDP / Maintenance)
  + 1 fichier Excel contenant les données patrimoniales
  + 1 Répertoire appelé **data_geographie** contenant les données géographiques
* L'application se compose des éléments suivants :
  + Un bandeau de gauche contenant les données d'entrée
  + Une carte géographique en haut de l'écran principal
  + Un tableau récapitulatif en bas de l'écran principal
* Au démarrage, la carte et le tableau sont vides.
* En haut du bandeau de gauche se trouvent les éléments de configuration d'affichage de la carte et du tableau :
  + Dans le champ **Répertoire des données**, renseigner le chemin d'accès complet au répertoire de données d'entrée. Si le chemin est correctement renseigné, la carte et le tableau s'affichent. S'affiche également la liste des années disponibles dans les données patrimoniales.
  + La carte et la tableau sont automatiquement mis à jour lorsque les champs **Equipement**, **Fond de carte RTE**, ou **Année** sont modifiés.
* En bas du bandeau de gauche se trouvent 3 boutons : 
  + Le bouton **Sauver** permet de sauvegarder les valeurs des champs renseignés pour une utilisation ultérieure.
  + Le bouton **Charger** permet de charger les valeurs des champs préalablement enregistrés.
  + Le bouton **Quitter** permet de quitter l'application.
* Au niveau de la carte :
  + La couleur correspond à l'âge moyen de l'équipement considéré dans la zone.
  + La valeur de l'âge moyen s'affiche en passant la souris sur la zone souhaitée.
  + Un clic gauche de la souris permet d'afficher les informations synthétiques de la zone.
* Au niveau du tableau :
  + Le tableau affiche les informations synthétiques de toutes les zones
  + Il est possible de filtrer les informations par nom de zone