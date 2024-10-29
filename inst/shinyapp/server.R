library(shiny)
library(massSight)
library(readr)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(doParallel)
library(foreach)
library(shinycssloaders)

server <- function(input, output, session) {
  # Reactive values to store data and objects
  data <- reactiveValues(df1 = NULL, df2 = NULL)
  ms_objects <- reactiveVal(NULL)
  aligned_object <- reactiveVal(NULL)
  log_content <- reactiveVal(NULL)

  # Observe first file upload
  observeEvent(input$file1, {
    req(input$file1)
    tryCatch(
      {
        data$df1 <- read_csv(input$file1$datapath)
        updateSelectInput(session, "id_name1", choices = names(data$df1))
        updateSelectInput(session, "rt_name1", choices = names(data$df1))
        updateSelectInput(session, "mz_name1", choices = names(data$df1))
        updateSelectInput(session, "int_name1", choices = names(data$df1))
        updateSelectInput(session, "metabolite_name1", choices = c("None", names(data$df1)))
      },
      error = function(e) {
        showNotification("Error reading first file. Please ensure it's a valid CSV.", type = "error")
      }
    )
  })

  # Observe second file upload
  observeEvent(input$file2, {
    req(input$file2)
    tryCatch(
      {
        data$df2 <- read_csv(input$file2$datapath)
        updateSelectInput(session, "id_name2", choices = names(data$df2))
        updateSelectInput(session, "rt_name2", choices = names(data$df2))
        updateSelectInput(session, "mz_name2", choices = names(data$df2))
        updateSelectInput(session, "int_name2", choices = names(data$df2))
        updateSelectInput(session, "metabolite_name2", choices = c("None", names(data$df2)))
      },
      error = function(e) {
        showNotification("Error reading second file. Please ensure it's a valid CSV.", type = "error")
      }
    )
  })

  # Create massSight objects
  observeEvent(input$create_ms_objects, {
    req(data$df1, data$df2)

    # Validate required columns
    required_cols1 <- c(input$id_name1, input$rt_name1, input$mz_name1, input$int_name1)
    required_cols2 <- c(input$id_name2, input$rt_name2, input$mz_name2, input$int_name2)

    if (!all(required_cols1 %in% names(data$df1))) {
      showNotification("First dataset is missing required columns.", type = "error")
      return(NULL)
    }
    if (!all(required_cols2 %in% names(data$df2))) {
      showNotification("Second dataset is missing required columns.", type = "error")
      return(NULL)
    }

    # Create MSObjects
    ms1 <- create_ms_obj(
      df = data$df1,
      name = "Dataset1",
      id_name = input$id_name1,
      rt_name = input$rt_name1,
      mz_name = input$mz_name1,
      int_name = input$int_name1,
      metab_name = if (input$metabolite_name1 != "None") input$metabolite_name1 else NULL
    )

    ms2 <- create_ms_obj(
      df = data$df2,
      name = "Dataset2",
      id_name = input$id_name2,
      rt_name = input$rt_name2,
      mz_name = input$mz_name2,
      int_name = input$int_name2,
      metab_name = if (input$metabolite_name2 != "None") input$metabolite_name2 else NULL
    )

    ms_objects(list(ms1 = ms1, ms2 = ms2))
    showNotification("MS Objects created successfully!", type = "message")
    updateTabsetPanel(session, "mainTabset", selected = "Parameters")
  })

  # Run Analysis
  observeEvent(input$run_analysis, {
    req(ms_objects())

    # Validate parameters
    if (input$iso_method == "dbscan" && is.null(input$eps)) {
      showNotification("Please provide an epsilon value for DBSCAN.", type = "error")
      return(NULL)
    }

    # Set up parallel backend if selected
    if (input$parallel) {
      numCores <- parallel::detectCores() - 1
      cl <- makeCluster(numCores)
      registerDoParallel(cl)
      on.exit(stopCluster(cl), add = TRUE)
    }

    # Run mass_combine with progress
    withProgress(message = "Running mass_combine...", value = 0, {
      aligned <- tryCatch(
        {
          mass_combine(
            ms1 = ms_objects()$ms1,
            ms2 = ms_objects()$ms2,
            rt_lower = input$rt_lower,
            rt_upper = input$rt_upper,
            mz_lower = input$mz_lower,
            mz_upper = input$mz_upper,
            minimum_intensity = input$minimum_intensity,
            iso_method = input$iso_method,
            eps = if (input$iso_method == "dbscan") input$eps else NULL,
            rt_iso_threshold = input$rt_iso_threshold,
            mz_iso_threshold = input$mz_iso_threshold,
            match_method = input$match_method,
            smooth_method = input$smooth_method,
            weights = as.numeric(strsplit(input$weights, ",")[[1]]),
            log = input$log_file,
            output = input$output_dir
          )
        },
        error = function(e) {
          showNotification(paste("Error during analysis:", e$message), type = "error")
          return(NULL)
        }
      )

      if (!is.null(aligned)) {
        aligned_object(aligned)
        incProgress(1)
        showNotification("Analysis completed successfully!", type = "message")
      }
    })
  })
  # Download Merged Results
  output$download_merged <- downloadHandler(
    filename = function() {
      paste("merged_results_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write_csv(all_matched(aligned_object()), file)
    }
  )

  # Render Log File Content
  output$log_view <- renderText({
    req(aligned_object())
    # Assuming log_content is stored within the aligned_object
    log_content(aligned_object()@log) # Adjust based on actual structure
  })

  # Download Log File
  output$download_log <- downloadHandler(
    filename = function() {
      paste("analysis_log_", Sys.Date(), ".txt", sep = "")
    },
    content = function(file) {
      writeLines(log_content(), file)
    }
  )
}