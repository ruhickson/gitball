# Load necessary libraries
install.packages("odbc")
install.packages("DBI")
library(odbc)
library(DBI)

# Load environment variables
readRenviron(".Renv")

# Database connection parameters
db_host <- Sys.getenv("DB_HOST")
db_port <- as.integer(Sys.getenv("DB_PORT"))
db_name <- Sys.getenv("DB_NAME")

# Create connection string for Azure AD authentication
conn_string <- paste0(
  "Driver={ODBC Driver 18 for SQL Server};",
  "Server=", db_host, ",", db_port, ";",
  "Database=", db_name, ";",
  "Encrypt=yes;",
  "TrustServerCertificate=no;",
  "Connection Timeout=30;",
  "Authentication=ActiveDirectoryDefault;"
)

# Create a connection
conn <- dbConnect(odbc::odbc(), .connection_string = conn_string)

# Check connection
if (!dbIsValid(conn)) {
  stop("Failed to connect to the database!")
}

# Example query: Fetch all records from the matches table
query <- "SELECT '1';"
result <- dbGetQuery(conn, query)

# Print the result
print(result)

# Close the connection
dbDisconnect(conn)

library(httr)

# API configuration
api_host <- Sys.getenv("API_HOST")
api_key <- Sys.getenv("API_KEY")

# Set up headers with the API key
headers <- add_headers(`Authorization` = paste("Bearer", api_key))

# Make the GET request with headers
response <- GET(url, headers)

api_data <- content(response$content,"text")

# Check the status code of the response
status_code <- status_code(response)
print(paste("Status code:", status_code))


# If the request was successful, parse the response
if (status_code == 200) {
  # Parse the content of the response as text
  content_text <- content(response, "text")
  
  # Print the raw JSON response as text
  print(content_text)
  
  # Parse the content as JSON
  content_json <- content(response, "parsed")
  
  # Print the parsed JSON as a list
  print(content_json)
} else {
  print("Failed to retrieve data")
}

# Define the URL for the API request
url <- "https://v3.football.api-sports.io/leagues"

# Set up the headers including the API key and host
headers <- c(
  `x-rapidapi-key` = api_key,
  `x-rapidapi-host` = api_host
)

# Make the GET request
response <- GET(url, headers)

# Print the status code
print(paste("Status code:", status_code(response)))

# Print the response content as text
response_text <- content(response, "text")
response_json <- content(response, "parsed")
print(response_json)

response_text
response_json
