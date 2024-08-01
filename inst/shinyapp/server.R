library(shiny)
library(massSight)
library(readr)
library(dplyr)
library(ggplot2)

server <- function(input, output, session) {
  
  data <- reactiveValues(df1 = NULL, df2 = NULL)
  ms_objects <- reactiveVal(NULL)
  
  observe({
    req(input$file1)
    data$df1 <- read_csv(input$file1$datapath)
    updateSelectInput(session, "id_name1", choices = names(data$df1))
    updateSelectInput(session, "rt_name1", choices = names(data$df1))
    updateSelectInput(session, "mz_name1", choices = names(data$df1))
    updateSelectInput(session, "int_name1", choices = names(data$df1))
    updateSelectInput(session, "metabolite_name1", choices = names(data$df1))
  })
  
  observe({
    req(input$file2)
    data$df2 <- read_csv(input$file2$datapath)
    updateSelectInput(session, "id_name2", choices = names(data$df2))
    updateSelectInput(session, "rt_name2", choices = names(data$df2))
    updateSelectInput(session, "mz_name2", choices = names(data$df2))
    updateSelectInput(session, "int_name2", choices = names(data$df2))
    updateSelectInput(session, "metabolite_name2", choices = names(data$df2))
  })
  
  observeEvent(input$create_ms_objects, {
    req(data$df1, data$df2)
    
    ms1 <- create_ms_obj(
      df = data$df1,
      name = "dataset1",
      id_name = input$id_name1,
      rt_name = input$rt_name1,
      mz_name = input$mz_name1,
      int_name = input$int_name1,
      metabolite_name = input$metabolite_name1
    )
    
    ms2 <- create_ms_obj(
      df = data$df2,
      name = "dataset2",
      id_name = input$id_name2,
      rt_name = input$rt_name2,
      mz_name = input$mz_name2,
      int_name = input$int_name2,
      metabolite_name = input$metabolite_name2
    )
    
    ms_objects(list(ms1 = ms1, ms2 = ms2))
    updateTabsetPanel(session, "mainTabset", selected = "parameters")
  })
  
  results <- eventReactive(input$run_analysis, {
    req(ms_objects())
    
    withProgress(message = 'Running analysis...', value = 0, {
      aligned <- auto_combine(
        ms_objects()$ms1,
        ms_objects()$ms2,
        rt_lower = input$rt_lower,
        rt_upper = input$rt_upper,
        mz_lower = input$mz_lower,
        mz_upper = input$mz_upper,
        smooth_method = input$smooth_method
      )
      
      incProgress(1)
      
      list(
        merged = all_matched(aligned),
        plots = final_plots(aligned,
                            rt_lim = c(input$rt_lower, input$rt_upper),
                            mz_lim = c(input$mz_lower, input$mz_upper))
      )
    })
  })
  
  output$merged_results <- renderDataTable({
    req(results())
    results()$merged
  })
  
  output$alignment_plots <- renderPlot({
    req(results())
    results()$plots
  })
  
  outputOptions(output, "merged_results", suspendWhenHidden = FALSE)
  outputOptions(output, "alignment_plots", suspendWhenHidden = FALSE)
}