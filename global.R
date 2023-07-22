#libraries
library(devtools)
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

#loading functions
devtools::load_all(quiet = T)
