#' @title Read
#' 
#' @description
#' Function reading equipment data base.
#' 
#' @param dirData (Character) Directory path name.
#' @param equipment (Character) Equipment name: "Disjoncteur", "Cable".
#' 
fRead <- function (dirData, equipment) {
  
  #reading equipment data base : NA values are excluded (read_xlsx option: na = "NA")
  #no name for 1st column. Solution: skip first row and rename all columns
  if (equipment=="Disjoncteur") {
    fileMat <- readxl::read_xlsx(path = file.path(dirData, "indicateurs_summer-challenge2023.xlsx"),
                                 sheet = "Disjoncteur", na = "NA", skip = 1,
                                 col_names = c("num", "ANNEE", "CM", "GMR", "GDP", "SITE", "ACTIF", "Nb", "Age"),
                                 col_types = c(rep("numeric", 2), rep("text", 5), rep("numeric", 2)))
  }
  else {
    fileMat <- readxl::read_xlsx(path = file.path(dirData, "indicateurs_summer-challenge2023.xlsx"),
                                 sheet = "Circuit souterrain - conducteur", na = "NA", skip = 1,
                                 col_names = c("num", "ANNEE", "CM", "GMR", "ACTIF", "Nb", "Age"),
                                 col_types = c(rep("numeric", 2), rep("text", 3), rep("numeric", 2)))
  }
  
  return(fileMat)
}