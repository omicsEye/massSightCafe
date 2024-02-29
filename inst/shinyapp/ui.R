library(shiny)

# Define UI for the application
ui <- fluidPage(
  titlePanel("massSightCafe"),
  sidebarLayout(
    sidebarPanel(
      helpText("Select your options"),
      fileInput("lcms_file1", "Upload first LC-MS experiment file:",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv",
                  "text/tab-separated-values",
                  ".tsv"
                )),
      fileInput("lcms_file2", "Upload second LC-MS experiment file:",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv",
                  "text/tab-separated-values",
                  ".tsv"
                )),
      uiOutput("varSelect1"), # Dynamically generated selectInput for file 1
      uiOutput("varSelect2") # Dynamically generated selectInput for file 2
    ),
    mainPanel(
      textOutput("myText")
    )
  )
)
