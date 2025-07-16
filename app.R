## Joshua Bugay
## July 16th, 2025
## Main Shiny app file


# UI
ui <- fluidPage(
 titlePanel("My Data Dashboard"),
 
 sidebarLayout(
  sidebarPanel(
   # Controls that trigger reactive expressions
   dateRangeInput("date_range", "Select Date Range"),
   selectInput("category", "Category", choices = NULL),
   actionButton("refresh_data", "Refresh Data")
  ),
  
  mainPanel(
   plotOutput("main_plot"),
   plotOutput("secondary_plot")
  )
 )
)

# Server
server <- function(input, output, session) {
 
 # Load data once per session, refresh on button click
 raw_data <- reactiveVal()
 
 # Initial data load and refresh mechanism
 observe({
  # Load data when app starts
  data <- fetch_github_data(GITHUB_REPO_URL)
  raw_data(data)
 })
 
 # Refresh data when button is clicked
 observeEvent(input$refresh_data, {
  # Force fresh data by removing cache
  cache_file <- "data/cache/github_data.rds"
  if (file.exists(cache_file)) file.remove(cache_file)
  
  data <- fetch_github_data(GITHUB_REPO_URL)
  raw_data(data)
 })
 
 # Update UI choices based on data
 observe({
  req(raw_data())
  choices <- unique(raw_data()$category)
  updateSelectInput(session, "category", choices = choices)
 })
 
 # Processed data - only recalculates when inputs change
 processed_data <- reactive({
  req(raw_data())
  
  filter_params <- list(
   date_range = input$date_range,
   category = input$category
  )
  
  transform_data(raw_data(), filter_params)
 })
 
 # Plots - only regenerate when processed_data changes
 output$main_plot <- renderPlot({
  req(processed_data())
  create_main_plot(processed_data())
 })
 
 output$secondary_plot <- renderPlot({
  req(processed_data())
  create_secondary_plot(processed_data())
 })
}

shinyApp(ui = ui, server = server)