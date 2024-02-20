
library(shiny)
library(rjson)
library(ggVennDiagram)
library(ggplot2)
library(plotly)
library(DT)



# --------- Read the JSON file to get variant list and their signatures --------
variants <- fromJSON(file = "Mutations_2023-May-05.json") 
names(variants) <- substring(names(variants), first = 1, last = nchar(names(variants))-10)


# =================================  UI  =======================================
ui <- shinyUI(fluidPage(

  titlePanel("Mutation Signatures of SARS-CoV-2 Variants"),
  
  sidebarLayout(
    # --- Input ---
    sidebarPanel(width = 2, 
        checkboxGroupInput("variant", label = "Variant:",
                           choiceNames = names(variants),
                           choiceValues = names(variants),
                           selected = names(variants)[1:2]
                           ),
        downloadButton("download1", "Download Figure"),
        downloadButton("download2", "Download Table")
    ),
    # --- Output ---
    mainPanel(width = 10,
        fluidRow(plotlyOutput("venn", width = "100%"), style = "height:800px"),
        fluidRow(column(dataTableOutput('intersectValue'), width = 12))
    )
  )#sidebarLayout
))#shinyUI



# ================================  SERVER  ====================================
server <- shinyServer(function(input, output) {
  
  # Getting user's input and retrieving signatures
  data <- reactive({
    req(input$variant)
    l <- list()
    for (s in input$variant) {
      l[s] = list(c(variants[[s]][["sites"]]))
    }
    as.list(l)
  })
  
  # Function for plotting Venn diagram
  # Modified from the source code of package ggVennDiagram, Github: https://github.com/gaospecial/ggVennDiagram
  # Reference: https://cran.rstudio.com/web/packages/ggVennDiagram/vignettes/fully-customed.html
  plt_venn <- function(x){
    venn <- Venn(x)
    venn_data <- process_data(venn)
    
    items <- venn_region(venn_data) %>%
        dplyr::rowwise() %>%
        dplyr::mutate(text = stringr::str_wrap(paste0(.data$item, collapse = ', '), width = 40)) %>%
        sf::st_as_sf()
    label_coord = sf::st_centroid(items$geometry) %>% sf::st_coordinates()
    
    ggplot(items) +
      geom_sf(aes_string(fill="count")) +
      geom_sf_text(aes_string(label = "name"), 
                   data = venn_data@setLabel,
                   inherit.aes = F,
                   size =6,fontface = "bold") +
      geom_text(aes_string(label = "count", text = "text"), 
                x = label_coord[,1], 
                y = label_coord[,2],
                show.legend = FALSE, 
                size=6,fontface = "bold") +
      theme_void() +
      scale_fill_distiller(palette = "Pastel1") + 
      scale_x_continuous(expand = expansion(mult = 0.2)) +
      theme(text=element_text(size=12, family="Arial"),
            legend.position = "none")
  }# ggplot object
  
  
  # Function for listing the signatures and their intersection relations in a table
  table_sig <- function(x){
    venn <- Venn(x)
    venn_data <- process_data(venn)
    
    dt <- data.frame(venn_data@region, stringsAsFactors = FALSE)[c('name', 'count', 'item')]
    colnames(dt) <- c('Variant sets','Intersecting mutation counts','Intersecting mutation') #Rename columns
    
    # string formatting
    str_format <- function(y){ 
      paste0(strsplit(toString(y), split = '\\.\\.')[[1]], collapse = ', ')
    }
    str_format2 <- function(z){ 
      paste0(strsplit(toString(unlist(z)), split = '\\,\\ ')[[1]], collapse = ', ')
    }
    dt['Variant sets'] <- apply(dt['Variant sets'], 1, str_format)
    dt['Intersecting mutation'] <- apply(dt['Intersecting mutation'], 1, str_format2)
    
    return(dt)
  }
  
  
  # ------------ output variables -----------
  # [1] The Venn diagram
  output$venn <- renderPlotly({
    # This is to show the intersect values when viewing with browser
    ax <- list(showline = FALSE)
    plotly::ggplotly(
      plt_venn(data()),
      tooltip = c("text"),
      height = 800,
      width = 1000 ) %>%
    plotly::layout(xaxis = ax, yaxis = ax) #plotly object
  })
  
  
  # [2] The data table
  output$intersectValue <- DT::renderDataTable(
    table_sig(data()),
    rownames = FALSE,
    options = list(scrollX = TRUE, 
                   order = list(list(1, 'desc')),
                   autoWidth = TRUE,
                   columnDefs = list(list(width = '150px', targets = 0),
                                     list(width = '120px', targets = 1),
                                     list(className = 'dt-center', targets = 1))
                   )
  )

  
  # [3] The Venn diagram for download 
  output$download1 <- downloadHandler(
    filename = function() {
      paste0('Venn_diagram_', Sys.Date(), '.png', sep='')
    },
    content = function(file) {
      ggsave(file, plot = plt_venn(data()), device = "png", 
             dpi = 200, width = 20, height = 18, units = "cm")
    }
  )
  
  
  # [4] The data table for download
  output$download2 <- downloadHandler(
    filename = function() {
      paste0('Mutaion_intersection_list_', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      write.csv(table_sig(data()), file)
    }
  )
  
})#shinyServer


# ==============================================================================

shinyApp(ui = ui, server = server)


