#' @title Clean
#' 
#' @description
#' Function reading equipment data base, cleaning it, and making it readable for leaflet mapping.
#' 
#' @param dirData (Character) Directory path name.
#' @param baseMap (Character) Base map name: "GMR", "Maintenance", "Site".
#' @param equipment (Character) Equipment name: "Disjoncteur", "Cable".
#' @param year (Character) Year of collecting equipment data.
#' 
#' @return Returns a Data.frame containing: location, mean age, number or length of equipment, and geographical data.
fClean <- function (dirData, baseMap, equipment, year) {
  
  #reading equipment data base
  fileMat <- fRead(dirData = dirData,
                   equipment = equipment)
  
  #reading base map
  fileBaseMap <- sf::st_read(dsn = file.path(dirData, "data_geographie"), layer = baseMap, quiet = T)
  
  #case GMR
  if (baseMap=="GMR") {
    
    #reading GMR correspondence file
    fileCor <- readxl::read_xlsx(path = file.path(dirData, "correspondance_division_localisation_nom_GMR.xlsx"))
    
    #cleaning base map data :
    #- filter by year
    #- select columns GMR, Nb, Age
    #- join with fileCor and fileBaseMap by GMR
    #- get total number or length of equipment and mean age per GMR
    #- select GMR, Nombre, Moyenne, geometry 
    dataResult <- fileMat %>%
      dplyr::filter(ANNEE==year) %>%
      dplyr::select(GMR, Nb, Age) %>%
      dplyr::left_join(fileCor, by = c('GMR'='fichier Indicateurs')) %>%
      dplyr::left_join(fileBaseMap, by = c('df_gmr$NOM_GMR'='NOM_GMR')) %>%
      dplyr::group_by(GMR, geometry) %>%
      dplyr::summarise(Nombre = sum(Nb, na.rm = T), Moyenne = mean(Age, na.rm = T)) %>%
      dplyr::ungroup() %>%
      dplyr::select(GMR, Nombre, Moyenne, geometry) %>%
      sf::st_as_sf()
    
  }
  #case Maintenance
  else if (baseMap=="Maintenance") {
    
    #reading CM correspondence file
    fileCor <- read.csv2(file = file.path(dirData, "correspondance_nom_maintenance.csv"), sep = ",")
    
    #cleaning base map data :
    #- filter by year
    #- select columns CM, Nb, Age
    #- join with fileCor and fileBaseMap by CM
    #- get total number or length of equipment and mean age per CM
    #- select CM, Nombre, Moyenne, geometry 
    dataResult <- fileMat %>%
      dplyr::filter(ANNEE==year) %>%
      dplyr::select(CM, Nb, Age) %>%
      dplyr::left_join(fileCor, by = c('CM'='nom3')) %>%
      dplyr::left_join(fileBaseMap, by = c('nom1'='NOM_MAINTE')) %>%
      dplyr::group_by(CM, geometry) %>%
      dplyr::summarise(Nombre = sum(Nb, na.rm = T), Moyenne = mean(Age, na.rm = T)) %>%
      dplyr::ungroup() %>%
      dplyr::select(CM, Nombre, Moyenne, geometry) %>%
      sf::st_as_sf()
    
  }
  #case Sites
  else if (baseMap=="Sites") {
    
    #no Site correspondence for underground cables
    if (equipment=="Cable") { return(1) }
    
    #cleaning base map data :
    #- filter by year
    #- select columns SITE, Nb, Age
    #- join with fileBaseMap by Site
    #- select SITE, Nombre, Moyenne, geometry 
    dataResult <- fileMat %>%
      dplyr::filter(ANNEE==year) %>%
      dplyr::select(SITE, Nb, Age) %>%
      dplyr::left_join(fileBaseMap, by = c('SITE'='IDR')) %>%
      dplyr::select(SITE, Nombre = Nb, Moyenne = Age, geometry) %>%
      dplyr::distinct() %>%
      sf::st_as_sf()
  }
  else if (baseMap=="GDP") {
    #reading GDP correspondence file
    fileCor <-  read.csv2(file = file.path(dirData, "correspondance_nom_GDP.csv"), sep = ",")
    
    #no GDP correspondence for underground cables
    if (equipment=="Cable") { return(1) }
    
    #- filter by year
    #- select columns GDP, Nb, Age
    #- join with fileCor and fileBaseMap by GDP
    #- get total number or length of equipment and mean age per GDP
    #- select GDP, Nombre, Moyenne, geometry 
    dataResult <- fileMat %>%
      dplyr::filter(ANNEE==year) %>%
      dplyr::select(GDP, Nb, Age) %>%
      dplyr::left_join(fileCor, by = c('GDP'='nom1')) %>%
      dplyr::left_join(fileBaseMap, by = c('nom3'='CODE_GDP')) %>%
      dplyr::group_by(GDP, geometry) %>%
      dplyr::summarise(Nombre = sum(Nb, na.rm = T), Moyenne = mean(Age, na.rm = T)) %>%
      dplyr::ungroup() %>%
      dplyr::select(GDP, Nombre, Moyenne, geometry) %>%
      sf::st_as_sf()
  }
  #rename columns: length for cables, number for circuit breakers.
  names(dataResult)[2:3] <- c(ifelse(equipment=="Disjoncteur", "Nombre total", "Longueur totale"), "Age moyen")
  
  return(dataResult)
}