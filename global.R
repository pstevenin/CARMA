#libraries
library(data.table)
library(dplyr)
library(DT)
library(tmap)
library(geojsonsf)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(stringr)

#hide warning messages from group_by/summarise functions
options(dplyr.summarise.inform = F)

#interactive view
tmap_mode("view")

#loading R functions in /R directory
file.sources = list.files(path = "/R", pattern = "*.R$", full.names = T,  ignore.case = T)
sapply(X = file.sources, FUN = source, simplify = .GlobalEnv)
