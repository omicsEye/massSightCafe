library(shiny)

ui <- fluidPage(
  titlePanel("massSightCafe"),
  
  tabsetPanel(id = "mainTabset",
    tabPanel("Data Upload",
      fluidRow(
        column(6,
          h4("First Dataset"),
          fileInput("file1", "Choose first CSV file", accept = ".csv"),
          selectInput("id_name1", "Compound ID column", choices = NULL),
          selectInput("rt_name1", "Retention Time column", choices = NULL),
          selectInput("mz_name1", "Mass-to-Charge Ratio column", choices = NULL),
          selectInput("int_name1", "Intensity column", choices = NULL),
          selectInput("metabolite_name1", "Metabolite Name column (optional)", choices = NULL)
        ),
        column(6,
          h4("Second Dataset"),
          fileInput("file2", "Choose second CSV file", accept = ".csv"),
          selectInput("id_name2", "Compound ID column", choices = NULL),
          selectInput("rt_name2", "Retention Time column", choices = NULL),
          selectInput("mz_name2", "Mass-to-Charge Ratio column", choices = NULL),
          selectInput("int_name2", "Intensity column", choices = NULL),
          selectInput("metabolite_name2", "Metabolite Name column (optional)", choices = NULL)
        )
      ),
      actionButton("create_ms_objects", "Create MS Objects", class = "btn-primary")
    ),
    
    tabPanel("Parameters",
      h4("Set Analysis Parameters"),
      numericInput("rt_lower", "RT Lower Bound", value = -0.5),
      numericInput("rt_upper", "RT Upper Bound", value = 0.5),
      numericInput("mz_lower", "MZ Lower Bound", value = -15),
      numericInput("mz_upper", "MZ Upper Bound", value = 15),
      selectInput("smooth_method", "Smoothing Method",
                  choices = c("gam", "loess", "lm"),
                  selected = "gam"),
      actionButton("run_analysis", "Run Analysis", class = "btn-success")
    ),
    
    tabPanel("Results",
      tabsetPanel(
        tabPanel("Merged Results",
                 h3("Merged Results"),
                 dataTableOutput("merged_results")),
        tabPanel("Alignment Plots",
                 plotOutput("alignment_plots", height = "600px"))
      )
    )
  )
)