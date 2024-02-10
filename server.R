#' @title Server
#' 
#' @description Server side for shiny app.
#' 
server <- function(input, output, session) {
  
  #load inputs
  observeEvent(input$load, {
    #loading if file exists
    if (file.exists("data/input.rda")) {
      load("data/input.rda")
      updateTextInput(inputId = "dirEco", value = input$dirEco)
      updateTextInput(inputId = "dirCol", value = input$dirCol)
      updateTextInput(inputId = "dirLyc", value = input$dirLyc)
      updateTextInput(inputId = "dirSec", value = input$dirSec)
      updateSelectInput(inputId = "freeSector", selected = input$freeSector)
      updateSelectInput(inputId = "freeNature", selected = input$freeNature)
      updateSelectInput(inputId = "gradSector", selected = input$gradSector)
      updateSelectInput(inputId = "gradNature", selected = input$gradNature)
    }
    else { showModal(modalDialog(title = "Fichier inexistant", size = "s", footer = modalButton("OK"), easyClose = T)) }
  })

  #save inputs
  observeEvent(input$save, {
    input <- data.frame(dirEco = input$dirEco,
                        dirCol = input$dirCol,
                        dirLyc = input$dirLyc,
                        dirSec = input$dirSec,
                        freeSector = input$freeSector,
                        freeNature = input$freeNature,
                        gradSector = input$gradSector,
                        gradNature = input$gradNature)
    save(input, file = "data/input.rda")
    showModal(modalDialog(title = "Données sauvegardées", size = "s", footer = modalButton("OK"), easyClose = T))
  })

  #exit app
  observeEvent(input$exit, { stopApp() })

  #free map
  #--------

  #all school data reading
  dataEco <- reactive({
    dataRes <- geojson_sf(req(input$dirEco))
    dataRes <- dataRes %>%
      filter(!is.na(coordonnee_x)) %>%
      filter(as.numeric(code_postal_uai)<97000) %>%
      mutate(nature = if_else(str_detect(nature_uai_libe, "COLLEGE"), "Collège",
                              if_else(str_detect(nature_uai_libe, "LYCEE"), "Lycée",
                                      if_else(str_detect(nature_uai_libe, "MATERNELLE"), "Maternelle",
                                              if_else(str_detect(nature_uai_libe, "ELEMENTAIRE"), "Primaire", "Autre")))))
  })

  #region
  output$uiFreeRegion <- renderUI({
    selectInput(inputId = "freeRegion", label = "Département", choices = sort(unique(dataEco()$libelle_departement)), selected = "Paris")
  })

  #map
  output$freeMap <- renderTmap({
    if (length(dataEco())>1) {
      dataMap <- dataEco() %>%
        filter(libelle_departement==req(input$freeRegion))
      if (input$freeSector!="Tous") {
        dataMap <- dataMap %>%
          filter(secteur_public_prive_libe==req(input$freeSector))
      }
      if (input$freeNature!="Tous") {
        dataMap <- dataMap %>%
          filter(nature==input$freeNature)
      }
      dataMap <- dataMap %>%
        select(c(26, 9, 28, 37, 27, 25))
      names(dataMap)[1:5] <- c("Nom", "Commune", "Adresse", "Nature", "Secteur")
      tm_shape(dataMap) +
        tm_symbols(col = "red", scale = .1, id = "appellation_officielle") +
        tm_basemap(server = "Esri.WorldTopoMap")
    }
    else { return(NULL) }
  })

  #graduation map
  #--------------

  #category
  output$uiGradCat <- renderUI({
    if (req(input$gradNature)=="Lycée") {
      selectInput(inputId = "gradCat", label = "Catégorie BAC", choices = c("L", "ES", "S"), selected = "S")
    }
  })

  #region
  output$uiGradRegion <- renderUI({
    if (req(input$gradNature)=="Lycée") {
      selectInput(inputId = "gradRegion", label = "Département", choices = sort(unique(dataLyc()$Departement)), selected = "PARIS")
    }
    else {
      selectInput(inputId = "gradRegion", label = "Département", choices = sort(unique(dataCol()$Département)), selected = "PARIS")
    }
  })

  #high school results data reading
  dataLyc <- reactive({
    dataRes <- fread(req(input$dirLyc))
    dataRes <- dataRes %>%
      group_by(UAI) %>%
      mutate(BacL = mean(`Taux de reussite - L`, na.rm = T),
             BacES = mean(`Taux de reussite - ES`, na.rm = T),
             BacS = mean(`Taux de reussite - S`, na.rm = T)) %>%
      select(c(1, 3, 4, 7, 146, 147, 148))
  })

  #college results data reading
  dataCol <- reactive({
    dataRes <- fread(req(input$dirCol))
    dataRes <- dataRes %>%
      group_by(UAI) %>%
      mutate(Brevet = mean(`Taux de réussite - G`, na.rm = T)) %>%
      select(c(2, 3, 4, 5, 25))
  })

  #map
  output$gradMap <- renderTmap({
    if (input$gradNature=="Lycée" & length(dataEco())>1 & length(dataLyc())>1) {
      dataMap <- merge(dataEco(), dataLyc(), by.x = "numero_uai", by.y = "UAI") %>%
        filter(Departement==req(input$gradRegion)) %>%
        select(c(1, 5, 10, 26, 27, 37, 39, 40, 41, 42, 43)) %>%
        unique()
      names(dataMap)[1:7] <- c("ID", "Code Postal", "Commune", "Secteur", "Adresse", "Nom", "Département")
      if (input$gradSector!="Tous") {
        dataMap <- dataMap %>%
          filter(Secteur==req(input$gradSector))
      }
      if (input$gradCat=="S") {
        tm_shape(dataMap) +
          tm_symbols(col = "BacS", id = "Nom", scale = 0.5, palette = "YlGn", popup.vars = c("Nom", "Secteur", "Adresse", "Commune", "BacS")) +
          tm_basemap(server = "Esri.WorldTopoMap")
      }
      else if (input$gradCat=="L") {
        tm_shape(dataMap) +
          tm_symbols(col = "BacL", id = "Nom", scale = 0.5, palette = "YlGn", popup.vars = c("Nom", "Secteur", "Adresse", "Commune", "BacL")) +
          tm_basemap(server = "Esri.WorldTopoMap")
      }
      else {
        tm_shape(dataMap) +
          tm_symbols(col = "BacES", id = "Nom", scale = 0.5, palette = "YlGn", popup.vars = c("Nom", "Secteur", "Adresse", "Commune", "BacES")) +
          tm_basemap(server = "Esri.WorldTopoMap")
      }

    }
    else if (input$gradNature=="Collège" & length(dataEco())>1 & length(dataCol())>1) {
      dataMap <- merge(dataEco(), dataCol(), by.x = "numero_uai", by.y = "UAI") %>%
        filter(Département==req(input$gradRegion)) %>%
        select(c(1, 5, 10, 26, 27, 37, 39, 40, 41)) %>%
        unique()
      names(dataMap)[1:7] <- c("ID", "Code Postal", "Commune", "Secteur", "Adresse", "Nom", "Département")
      if (input$gradSector!="Tous") {
        dataMap <- dataMap %>%
          filter(Secteur==req(input$gradSector))
      }
      tm_shape(dataMap) +
        tm_symbols(col = "Brevet", id = "Nom", scale = 0.5, palette = "YlGn", popup.vars = c("Nom", "Secteur", "Adresse", "Commune", "Brevet")) +
        tm_basemap(server = "Esri.WorldTopoMap")
    }
    else { return(NULL) }
  })

  #Sectors
  #-------

  #sectors data table
  dataSector <- reactive({
    dataRes <- fread(req(input$dirSec))
  })

  #region
  output$uiSecRegion <- renderUI({
    selectInput(inputId = "secRegion", label = "Département", choices = sort(unique(dataSector()$libelle_departement)), selected = "PARIS")
  })

  #city
  output$uiSecCity <- renderUI({
    dataRes <- dataSector() %>%
      filter(libelle_departement==req(input$secRegion))
    selectInput(inputId = "secCity", label = "Commune", choices = sort(unique(dataRes$libelle_commune)))
  })

  #street
  output$uiSecStreet <- renderUI({
    dataRes <- dataSector() %>%
      filter(libelle_departement==req(input$secRegion) & libelle_commune==req(input$secCity))
    selectInput(inputId = "secStreet", label = "Rue", choices = sort(unique(dataRes$type_et_libelle)))
  })
  
  #table
  output$secTab <- renderDataTable({
    if (length(dataSector())>1) {
      dataRes <- dataSector() %>%
        filter(libelle_departement==req(input$secRegion) & libelle_commune==req(input$secCity) & type_et_libelle==req(input$secStreet))
      dataRes <- merge(dataRes, dataCol(), by.x = "code_rne", by.y = "UAI") %>%
        select(c(7, 10, 12, 17, 19, 22))
      names(dataRes) <- c("Département", "Commune", "Voie", "Numéro", "Nom Collège", "Taux de réussite")
      return(dataRes)
    }
    else { return(NULL) }
  })
  
}
