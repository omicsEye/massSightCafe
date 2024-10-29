library(shiny)
library(shinythemes)
library(shinycssloaders)
library(magrittr)

ui <- fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("massSightCafe: Metabolomics Data Integration"),
  tabsetPanel(
    id = "mainTabset",
    tabPanel(
      "Data Upload",
      sidebarLayout(
        sidebarPanel(
          h4("First Dataset"),
          fileInput("file1", "Choose First CSV File", accept = ".csv"),
          selectInput("id_name1", "ID Column", choices = NULL),
          selectInput("rt_name1", "RT Column", choices = NULL),
          selectInput("mz_name1", "m/z Column", choices = NULL),
          selectInput("int_name1", "Intensity Column", choices = NULL),
          selectInput("metabolite_name1", "Metabolite Name Column (optional)", choices = NULL),
          hr(),
          h4("Second Dataset"),
          fileInput("file2", "Choose Second CSV File", accept = ".csv"),
          selectInput("id_name2", "ID Column", choices = NULL),
          selectInput("rt_name2", "RT Column", choices = NULL),
          selectInput("mz_name2", "m/z Column", choices = NULL),
          selectInput("int_name2", "Intensity Column", choices = NULL),
          selectInput("metabolite_name2", "Metabolite Name Column (optional)", choices = NULL),
          hr(),
          actionButton("create_ms_objects", "Create MS Objects", class = "btn-primary")
        ),
        mainPanel(
          h4("Preview First Dataset"),
          DT::dataTableOutput("preview1") %>% withSpinner(),
          hr(),
          h4("Preview Second Dataset"),
          DT::dataTableOutput("preview2") %>% withSpinner()
        )
      )
    ),
    tabPanel(
      "Parameters",
      sidebarLayout(
        sidebarPanel(
          h4("Alignment Parameters"),
          numericInput("rt_lower", "RT Lower Bound", value = -0.5),
          numericInput("rt_upper", "RT Upper Bound", value = 0.5),
          numericInput("mz_lower", "m/z Lower Bound", value = -15),
          numericInput("mz_upper", "m/z Upper Bound", value = 15),
          numericInput("minimum_intensity", "Minimum Intensity", value = 10),
          selectInput("iso_method", "Isolation Method",
            choices = c("manual", "dbscan"),
            selected = "manual"
          ),
          conditionalPanel(
            condition = "input.iso_method == 'dbscan'",
            numericInput("eps", "DBSCAN Epsilon", value = 0.1)
          ),
          numericInput("rt_iso_threshold", "RT Isolation Threshold", value = 0.1),
          numericInput("mz_iso_threshold", "m/z Isolation Threshold", value = 5),
          selectInput("match_method", "Matching Method",
            choices = c("unsupervised", "supervised"),
            selected = "unsupervised"
          ),
          selectInput("smooth_method", "Smoothing Method",
            choices = c("gam", "gaussian"),
            selected = "gam"
          ),
          textInput("weights", "Weights (comma-separated)", value = "1,1,1"),
          checkboxInput("parallel", "Enable Parallel Processing", value = FALSE),
          hr(),
          h4("Logging"),
          textInput("log_file", "Log File Name", value = "log.json"),
          textInput("output_dir", "Output Directory (optional)", value = ""),
          actionButton("run_analysis", "Run Analysis", class = "btn-success")
        ),
        mainPanel(
          h4("Parameter Guidance"),
          helpText("Adjust the parameters to fine-tune the alignment process.
                   Enable parallel processing to speed up computations on multi-core systems.")
        )
      )
    ),
    tabPanel(
      "Results",
      sidebarLayout(
        sidebarPanel(
          downloadButton("download_merged", "Download Merged Results"),
          downloadButton("download_log", "Download Log File")
        ),
        mainPanel(
          tabsetPanel(
            tabPanel(
              "Merged Results",
              h3("Merged Results"),
              DT::dataTableOutput("merged_results") %>% withSpinner()
            ),
            tabPanel(
              "Log File",
              h3("Analysis Log"),
              verbatimTextOutput("log_view") %>% withSpinner()
            )
          )
        )
      )
    ),
    tabPanel(
      "Help",
      fluidPage(
        h3("massSightCafe Help"),
        p("Welcome to massSightCafe! This application allows you to combine and align two LC-MS datasets using the `mass_combine` function from the `massSight` package."),
        h4("Steps to Use:"),
        tags$ol(
          tags$li("Go to the 'Data Upload' tab and upload your two CSV files."),
          tags$li("Select the appropriate columns for Compound ID, Retention Time (RT), m/z Ratio (MZ), Intensity, and optionally Metabolite Name."),
          tags$li("Click on 'Create MS Objects' to process the uploaded data."),
          tags$li("Navigate to the 'Parameters' tab to adjust alignment settings as needed."),
          tags$li("Click on 'Run Analysis' to perform the alignment."),
          tags$li("View and download the results in the 'Results' tab.")
        ),
        h4("Parameter Descriptions:"),
        tags$ul(
          tags$li(strong("RT Lower/Upper Bound:"), " Define the retention time window for aligning metabolites."),
          tags$li(strong("m/z Lower/Upper Bound:"), " Define the m/z ratio window for aligning metabolites."),
          tags$li(strong("Minimum Intensity:"), " Set the threshold for minimum intensity to consider a feature."),
          tags$li(strong("Isolation Method:"), " Choose between 'manual' and 'dbscan' for isolating compounds."),
          tags$li(strong("DBSCAN Epsilon:"), " Set the epsilon value for the DBSCAN algorithm (only if 'dbscan' is selected)."),
          tags$li(strong("RT/m/z Isolation Threshold:"), " Define thresholds for isolating compounds based on RT and m/z."),
          tags$li(strong("Matching Method:"), " Select 'unsupervised' or 'supervised' for initial matching."),
          tags$li(strong("Smoothing Method:"), " Choose the method for smoothing drift ('gam' or 'gaussian')."),
          tags$li(strong("Weights:"), " Assign weights for alignment factors, separated by commas."),
          tags$li(strong("Parallel Processing:"), " Enable to utilize multiple cores for faster computation."),
          tags$li(strong("Log File Name:"), " Specify the name for the analysis log file."),
          tags$li(strong("Output Directory:"), " Define where to save the output files. Leave blank to use the current directory.")
        ),
        h4("Contact"),
        p("For further assistance, please contact the development team at [email@example.com].")
      )
    )
  )
)
