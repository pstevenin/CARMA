#libraries
library(dplyr)
library(DT)
library(leaflet)
library(leafpop)
library(mapview)
library(RColorBrewer)
library(readxl)
library(sf)
library(shiny)
library(shinydashboard)
library(shinyWidgets)

#hide warning messages from group_by/summarise functions
options(dplyr.summarise.inform = F)

#loading R functions in /R directory
file.sources = list.files(path = "/R", pattern = "*.R$", full.names = T,  ignore.case = T)
sapply(X = file.sources, FUN = source, simplify = .GlobalEnv)
