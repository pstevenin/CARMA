#' @title UI
#' 
#' @description User interface side for shiny app.
#' 
ui <- dashboardPage(
  
  #title
  dashboardHeader(title = "Ecoles"),

  #configuration
  dashboardSidebar(
    sidebarMenu(
      menuItem("Configuration", tabName = "config"),
      menuItem("Navigation", tabName = "free"),
      menuItem("Diplômes", tabName = "grad"),
      menuItem("Sectorisation", tabName = "sector")
    ),
    #buttons
    tags$footer(
      actionBttn(inputId = "load", label = "Charger", style = "stretch", icon = icon("upload"), size = "sm"),
      actionBttn(inputId = "save", label = "Sauver", style = "stretch", icon = icon("save"), size = "sm"),
      actionBttn(inputId = "exit", label = "Quitter", style = "stretch", icon = icon("times-circle"), size = "sm", color = "danger"),
      style = "bottom:0; width:100%; position:fixed;"
      )
    ),

  #map and table
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "config",
        textInput(inputId = "dirEco", label = "Répertoire Ecoles"),
        textInput(inputId = "dirCol", label = "Résultats Collèges"),
        textInput(inputId = "dirLyc", label = "Répertoire Lycées"),
        textInput(inputId = "dirSec", label = "Répertoire Sectorisation")
        ),
      tabItem(
        tabName = "free",
        flowLayout(
          selectInput("freeSector", "Secteur", choices = c("Public", "Privé", "Tous"), selected = "Tous"),
          uiOutput("uiFreeRegion", width = 4),
          selectInput("freeNature", "Nature", choices = c("Maternelle", "Primaire", "Collège", "Lycée", "Autre", "Tous"), selected = "Tous")
          ),
        tmapOutput("freeMap", height = 700)
        ),
      tabItem(
        tabName = "grad",
        flowLayout(
          selectInput("gradSector", "Secteur", choices = c("Public", "Privé", "Tous"), selected = "Tous"),
          uiOutput("uiGradRegion"),
          selectInput("gradNature", "Nature", choices = c("Collège", "Lycée"), selected = "Lycée"),
          uiOutput("uiGradCat")
          ),
        tmapOutput("gradMap", height = 700)
        ),
      tabItem(
        tabName = "sector",
        uiOutput("uiSecRegion"),
        uiOutput("uiSecCity"),
        uiOutput("uiSecStreet"),
        dataTableOutput("secTab")
        )
      )
    )
  )
