# git_init.R
# Central control script for initializing tables in the database using API-Football
readRenviron(".Renv")

print(Sys.getenv("DB_HOST"))
print(Sys.getenv("DB_PORT"))
print(Sys.getenv("DB_NAME"))
print(Sys.getenv("AZURE_CLIENT_ID"))
print(Sys.getenv("AZURE_CLIENT_SECRET"))

db_host <- Sys.getenv("DB_HOST")
db_port <- as.integer(Sys.getenv("DB_PORT"))
db_name <- Sys.getenv("DB_NAME")
client_id <- Sys.getenv("AZURE_CLIENT_ID")
client_secret <- Sys.getenv("AZURE_CLIENT_SECRET")

# API-Football direct key usage
api_key <- Sys.getenv("API_KEY")
headers <- c(`x-apisports-key` = api_key)

# Create connection string
conn_string <- paste0(
  "Driver={ODBC Driver 18 for SQL Server};",
  "Server=tcp:", db_host, ",", db_port, ";",
  "Database=", db_name, ";",
  "Encrypt=yes;",
  "TrustServerCertificate=no;",
  "Connection Timeout=30;",
  "Authentication=ActiveDirectoryServicePrincipal;",
  "UID=", client_id, ";",
  "PWD=", client_secret
)

# Connect to the database
conn <- DBI::dbConnect(
  odbc::odbc(),
  .connection_string = conn_string,
  timeout = 10
)

# Source all initialise scripts
# devtools::load_all() # If using a package structure, otherwise comment out
source("initialise_leagues.R")
source("initialise_teams.R")
source("initialise_players.R")
source("initialise_fixtures.R")
source("initialise_events.R")
source("initialise_player_match_stats.R")

# Example usage (Premier League 2024)
premier_league_id <- 39
current_season <- 2024

# Uncomment the lines below to initialise specific tables:
# initialise_leagues(conn, headers)
# initialise_teams(conn, headers, premier_league_id, current_season)
# initialise_players(conn, headers, premier_league_id, current_season)
initialise_fixtures(conn, headers, premier_league_id, current_season)
# initialise_events(conn, headers, premier_league_id, current_season)
# initialise_player_match_stats(conn, headers, premier_league_id, current_season)

DBI::dbDisconnect(conn)
cat("Database initialisation completed!\n") 