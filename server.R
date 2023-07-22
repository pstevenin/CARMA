#' @title Server
#' 
#' @description Server side for shiny app.
#' 
#' @param input description
#' @param output description
#' @param session description
#' 
server <- function(input, output, session) {
  
  #reading load.RDS file
  lLoad <- shiny::reactiveValues(data = {
    if (file.exists("load.RDS")) { readRDS(file = "load.RDS") }
  })
  
  #load inputs
  shiny::observeEvent(input$load, {
    #loading if file exists
    if (file.exists("load.RDS")) {
      shiny::updateTextInput(inputId = "dirData", value = lLoad$data[[1]])
      shiny::updateSelectInput(inputId = "baseMap", selected = lLoad$data[[2]])
    }
    else { shiny::showModal(shiny::modalDialog(title = "Fichier inexistant", size = "s", footer = shiny::modalButton("OK"), easyClose = T)) }
  })
  
  #save inputs
  shiny::observeEvent(input$save, {
    lInput <- list()
    lInput[[1]] <- input$dirData
    lInput[[2]] <- input$baseMap
    saveRDS(lInput, "load.RDS")
    shiny::showModal(shiny::modalDialog(title = "Données sauvegardées", size = "s", footer = shiny::modalButton("OK"), easyClose = T))
  })
  
  #exit app
  shiny::observeEvent(input$exit, { shiny::stopApp() })
  
  #display available base maps depending on equipment
  output$uiBaseMap <- renderUI({
    if (input$equipment=="Disjoncteur") {
      selectInput(inputId = "baseMap", label = "Fond de carte RTE", choices = c("GMR", "Maintenance", "Sites"))
    }
    else {
      selectInput(inputId = "baseMap", label = "Fond de carte RTE", choices = c("GMR", "Maintenance"))
    }
  })
  
  #display available years in data base depending on equipment
  output$uiYear <- renderUI({
    #reading equipment data base
    fileMat <- fRead(dirData = req(input$dirData),
                     equipment = req(input$equipment))
    selectInput(inputId = "year", label = "Année", choices = sort(unique(fileMat$ANNEE)))
  })
  
  #reactive data cleaning: map is updated each time an input is changed
  dataMap <- reactive({
    fClean(dirData = req(input$dirData),
           baseMap = req(input$baseMap),
           equipment = req(input$equipment),
           year = req(input$year))
  })
  
  #display map
  output$map <- tmap::renderTmap({
    #unwanted case: underground cables by Sites
    if (length(dataMap())==1) { return(NULL) }
    #other cases
    else {
      #map with polygons for GMR, Maintenance and GDP
      if (class(dataMap()$geometry)[1]=="sfc_MULTIPOLYGON") {
        tmap::tm_basemap(server = "OpenStreetMap.France") +
          tmap::tm_shape(shp = dataMap(), name = req(input$baseMap)) +
          tmap::tm_fill(col = "moyenne", palette = "Reds", alpha = 0.5)
      }
      #map with points for Sites
      else {
        tmap::tm_basemap(server = "OpenStreetMap.France") +
          tm_shape(shp = dataMap(), name = req(input$baseMap)) +
          tm_dots(col = "moyenne", alpha = 0.5, palette = "Reds")
      }
    }
  })
  
  #display table
  output$table <- DT::renderDataTable({
    #unwanted case: underground cables by Sites
    if (length(dataMap())==1) { return(NULL) }
    #other cases
    else {
      dataResult <- dataMap() %>%
        sf::st_drop_geometry()
    }
  })
  
}
