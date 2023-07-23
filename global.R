#libraries
library(dplyr)
library(DT)
library(readxl)
library(sf)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tmap)

#hide warning messages from summarise function
options(dplyr.summarise.inform = FALSE)

#interactive map
tmap::tmap_mode(mode = "view")

#loading R functions
file.sources = list.files(path = "/R", pattern = "*.R$", full.names = T,  ignore.case = T)
sapply(X = file.sources, FUN = source, simplify = .GlobalEnv)
