#' @title Server
#' 
#' @description Server side for shiny app.
#' 
server <- function(input, output, session) {
  
  #load inputs
  shiny::observeEvent(input$load, {
    #loading if file exists
    if (file.exists("data/input.rda")) {
      load("data/input.rda")
      shiny::updateTextInput(inputId = "dirData", value = input$dirData)
      shiny::updateSelectInput(inputId = "equipment", selected = input$equipment)
      shiny::updateSelectInput(inputId = "baseMap", selected = input$baseMap)
    }
    else { shiny::showModal(shiny::modalDialog(title = "Fichier inexistant", size = "s", footer = shiny::modalButton("OK"), easyClose = T)) }
  })
  
  #save inputs
  shiny::observeEvent(input$save, {
    input <- data.frame(dirData = input$dirData,
                        equipment = input$equipment,
                        baseMap = input$baseMap)
    save(input, file = "data/input.rda")
    shiny::showModal(shiny::modalDialog(title = "Données sauvegardées", size = "s", footer = shiny::modalButton("OK"), easyClose = T))
  })
  
  #exit app
  shiny::observeEvent(input$exit, { shiny::stopApp() })
  
  #display available years in data base depending on equipment
  output$uiYear <- renderUI({
    #reading equipment data base (function in read.R)
    fileMat <- fRead(dirData = req(input$dirData),
                     equipment = req(input$equipment))
    #display list
    shiny::selectInput(inputId = "year", label = "Année", choices = sort(unique(fileMat$ANNEE)))
  })
  
  #reactive data cleaning: map updated when input changes
  dataMap <- shiny::reactive({
    #function in clean.R
    fClean(dirData = req(input$dirData),
           baseMap = req(input$baseMap),
           equipment = req(input$equipment),
           year = req(input$year))
  })
  
  #display map
  output$map <- leaflet::renderLeaflet({
    #unwanted cases: no underground cables by Sites or GDP
    if (length(dataMap())==1) { 
      shiny::showModal(shiny::modalDialog(title = "Données absentes", size = "s", footer = shiny::modalButton("OK"), easyClose = T))
      return(NULL)
    }
    #other cases
    else {
      #color scales (using RColorBrewer palettes):
      #- minimum: function floor to get the first integer lower or equal to minimum value
      #- maximum: function ceiling to get the first integer upper or equal to maximum value
      #- step: minimum between 9 (palette max number of colors) and number of different values in database
      minScale <- floor(min(dataMap()$'Age moyen', na.rm = T))
      maxScale <- ceiling(max(dataMap()$'Age moyen', na.rm = T))
      stepScale <- min(9, length(unique(dataMap()$'Age moyen')))
      #mapping: use of popupTable to display table when click on location
      mapview::mapView(dataMap(), zcol = "Age moyen", layer.name = req(input$baseMap),
                       col.region = RColorBrewer::brewer.pal(stepScale, "YlOrRd"), at = seq(minScale, maxScale, (maxScale-minScale)/(stepScale-1)),
                       popup = leafpop::popupTable(sf::st_drop_geometry(dataMap()), feature.id = F, row.numbers = F))@map
    }
  })
  
  #display table
  output$table <- DT::renderDataTable({
    #unwanted case: no underground cables by Sites or GDP
    if (length(dataMap())==1) { return(NULL) }
    #other cases
    else {
      dataResult <- dataMap() %>%
        sf::st_drop_geometry()
    }
  })
  
}
