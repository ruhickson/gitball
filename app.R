
# app.R
library(shiny)
library(DBI)
library(RPostgres)
library(DT)

# Define UI for the application
ui <- fluidPage(
  # Application title
  titlePanel("Prickball Data Viewer"),
  
  # Sidebar with navigation
  sidebarLayout(
    sidebarPanel(
      # Navigation buttons
      actionButton("show_leaderboard", "Leaderboard"),
      actionButton("show_eventlog", "Event Log")
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      uiOutput("page_content")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Connect to the PostgreSQL database
  con <- dbConnect(
    RPostgres::Postgres(),
    dbname = "prickball",
    host = "prickball.c1quoio6ew4m.eu-west-1.rds.amazonaws.com",
    port = 5432,
    user = "prickballadmin",
    password = "fussballlieb3_"
  )
  
  # Load the Leaderboard table
  leaderboard_data <- reactive({
    query <- "SELECT * FROM leaderboard;"
    dbGetQuery(con, query)
  })
  
  # Load the Events table
  eventlog_data <- reactive({
    query <- "SELECT * FROM events;"
    dbGetQuery(con, query)
  })
  
  # Observe the button clicks
  observeEvent(input$show_leaderboard, {
    output$page_content <- renderUI({
      DTOutput("leaderboard_table")
    })
    output$leaderboard_table <- renderDT({
      leaderboard_data()
    })
  })
  
  observeEvent(input$show_eventlog, {
    output$page_content <- renderUI({
      DTOutput("eventlog_table")
    })
    output$eventlog_table <- renderDT({
      eventlog_data()
    })
  })
  
  # Clean up database connection on exit
  onStop(function() {
    dbDisconnect(con)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
