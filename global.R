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


#hide warning messages from summarise function
options(dplyr.summarise.inform = F)

#loading R functions
file.sources = list.files(path = "/R", pattern = "*.R$", full.names = T,  ignore.case = T)
sapply(X = file.sources, FUN = source, simplify = .GlobalEnv)
