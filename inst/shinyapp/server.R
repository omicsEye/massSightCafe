library(shiny)
library(readr)

server <- function(input, output, session) {
  output$myText <- renderText({ "Welcome to massSightCafe!" })

  # Render UI for selecting variables from the first file
  output$varSelect1 <- renderUI({
    req(input$lcms_file1)
    # Read only the header to get column names
    colNames <- names(readr::read_csv(input$lcms_file1$datapath, n_max = 0))
    selectInput("selectedVars1", "Select variables for File 1:", choices = colNames, multiple = TRUE)
  })

  # Render UI for selecting variables from the second file
  output$varSelect2 <- renderUI({
    req(input$lcms_file2)
    colNames <- names(readr::read_csv(input$lcms_file2$datapath, n_max = 0))
    selectInput("selectedVars2", "Select variables for File 2:", choices = colNames, multiple = TRUE)
  })

  # Example of using the selected variables (further implementation needed based on the application's logic)
  observe({
    input$selectedVars1 # Use this input value for processing the first file
    input$selectedVars2 # Use this input value for processing the second file
    # Implement your data processing logic here
  })
}
