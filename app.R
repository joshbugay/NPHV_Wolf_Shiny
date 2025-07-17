## Joshua Bugay
## July 16th, 2025
## Main Shiny app file
library(tidyverse)
# UI
ui <- fluidPage(
 titlePanel("GitHub Data Dashboard"),
 
 sidebarLayout(
  sidebarPanel(
   h4("Data Controls"),
   
   # Date range filter
   dateRangeInput(
    "date_range", 
    "Select Date Range:",
    start = Sys.Date() - 365,
    end = Sys.Date()
   ),
   
   # Refresh button
   actionButton(
    "refresh_data", 
    "Refresh Data from GitHub",
    class = "btn-primary"
   ),
   
   br(), br(),
   
   # Data status
   verbatimTextOutput("data_status")
  ),
  
  mainPanel(
   tabsetPanel(
    tabPanel(
     "Temporal",
     plotOutput("main_plot", height = "400px")
    ),
    tabPanel(
     "Spatial", 
     plotOutput("secondary_plot", height = "400px")
    )
    )
   )
  )
 )

# Server
server <- function(input, output, session) {
 
 # Reactive value to store all raw data
 all_raw_data <- reactiveVal()
 
 # Initial data load when app starts
 observe({
  cat("Loading initial data...\n")
  data <- fetch_all_github_data()
  all_raw_data(data)
 })
 
 # Refresh data when button is clicked
 observeEvent(input$refresh_data, {
  cat("Refreshing data from GitHub...\n")
  
  # Show notification
  showNotification("Refreshing data from GitHub...", type = "message")
  
  # Clear cache for all files
  cache_files <- file.path("data/cache", paste0(names(GITHUB_URLS), ".rds"))
  lapply(cache_files, function(f) {
   if (file.exists(f)) {
    file.remove(f)
    cat("Removed cache file:", f, "\n")
   }
  })
  
  # Fetch fresh data
  data <- fetch_all_github_data()
  all_raw_data(data)
  
  showNotification("Data refreshed successfully!", type = "message")
 })
 
 # Processed data - only recalculates when inputs change
 processed_data <- reactive({
  req(all_raw_data())
  
  filter_params <- list(
   date_range = input$date_range
  )
  transform_data(all_raw_data(), filter_params)
 })
 
 # Data status output
 output$data_status <- renderText({
  if (is.null(all_raw_data())) {
   "No data loaded"
  } else {
   data_info <- character()
   for (dataset_name in names(all_raw_data())) {
    dataset <- all_raw_data()[[dataset_name]]
    if (!is.null(dataset)) {
     data_info <- c(data_info, paste(dataset_name, ":", nrow(dataset), "rows"))
    } else {
     data_info <- c(data_info, paste(dataset_name, ": Failed to load"))
    }
   }
   paste(data_info, collapse = "\n")
  }
 })
 
 # Main plot
 output$main_plot <- renderPlot({
  req(processed_data())
  
  if (nrow(processed_data()) == 0) {
   # Empty plot if no data
   ggplot() + 
    geom_text(aes(x = 1, y = 1, label = "No data available"), size = 6) +
    theme_void()
  } else {
   create_main_plot(processed_data())
  }
 })
 
 # Secondary plot
 output$secondary_plot <- renderPlot({
  req(processed_data())
  
  if (nrow(processed_data()) == 0) {
   # Empty plot if no data
   ggplot() + 
    geom_text(aes(x = 1, y = 1, label = "No data available"), size = 6) +
    theme_void()
  } else {
   create_secondary_plot(processed_data())
  }
 })
 
 # Handle errors gracefully
 observe({
  req(all_raw_data())
  
  # Check if any datasets failed to load
  failed_datasets <- names(all_raw_data())[sapply(all_raw_data(), is.null)]
  
  if (length(failed_datasets) > 0) {
   showNotification(
    paste("Failed to load:", paste(failed_datasets, collapse = ", ")),
    type = "warning",
    duration = 5
   )
  }
 })
}

# Run the application
shinyApp(ui = ui, server = server)