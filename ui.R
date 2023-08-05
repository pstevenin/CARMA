#' @title UI
#' 
#' @description User interface for shiny app.
#' 
ui <- shinydashboard::dashboardPage(
  
  #title
  shinydashboard::dashboardHeader(title = "CARMA V1.0"),
  
  #configuration
  shinydashboard::dashboardSidebar(
    shiny::textInput(inputId = "dirData", label = "Répertoire des données"),
    shiny::selectInput(inputId = "equipment", label = "Equipement", choices = c("Câble souterrain" = "Cable", "Disjoncteur" = "Disjoncteur")),
    shiny::selectInput(inputId = "baseMap", label = "Fond de carte RTE", choices = c("GMR", "Maintenance", "Sites", "GDP")),
    shiny::uiOutput(outputId = "uiYear"),
    shiny::tags$footer(
      shinyWidgets::actionBttn(inputId = "load", label = "Charger", style = "stretch", icon = icon("upload"), size = "sm"),
      shinyWidgets::actionBttn(inputId = "save", label = "Sauver", style = "stretch", icon = icon("save"), size = "sm"),
      shinyWidgets::actionBttn(inputId = "exit", label = "Quitter", style = "stretch", icon = icon("times-circle"), size = "sm", color = "danger"),
      style = "bottom:0; width:100%; position:fixed;"
      )
    ),
  
  #graph and table
  shinydashboard::dashboardBody(
    shiny::fluidRow(
      shinydashboard::box(
        width = 12,
        leaflet::leafletOutput(outputId = "map")
        ),
      shinydashboard::box(
        width = 12,
        DT::dataTableOutput(outputId = "table")
        )
      )
    )
  )
