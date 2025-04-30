library(odbc)
library(DBI)
library(httr)
library(jsonlite)
library(AzureAuth)
library(AzureRMR)

# Load environment variables
readRenviron(".Renv")

# Verify ODBC drivers are installed
print("Available ODBC drivers:")
print(odbc::odbcListDrivers())

# Database connection parameters
db_host <- Sys.getenv("DB_HOST")
db_port <- as.integer(Sys.getenv("DB_PORT"))
db_name <- Sys.getenv("DB_NAME")
tenant_id <- Sys.getenv("AZURE_TENANT_ID")
client_id <- Sys.getenv("AZURE_CLIENT_ID")
client_secret <- Sys.getenv("AZURE_CLIENT_SECRET")

# Debug print environment variables
print("Environment variables:")
print(paste("Tenant ID:", tenant_id))
print(paste("Client ID:", client_id))

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

print("Attempting to connect with connection string:")
print(conn_string)

# Connect to the database
conn <- dbConnect(
  odbc::odbc(),
  .connection_string = conn_string,
  timeout = 10
)

# Verify connection
if (dbIsValid(conn)) {
  print("Successfully connected to the database!")
} else {
  stop("Failed to connect to the database!")
}

# API configuration
api_host <- Sys.getenv("API_HOST")
api_key <- Sys.getenv("API_KEY")

# Set up the headers including the API key and host
headers <- c(
  `x-rapidapi-key` = api_key,
  `x-rapidapi-host` = api_host
)

# Drop tables in dependency order (children first)
dbExecute(conn, "DROP TABLE IF EXISTS events;")
dbExecute(conn, "DROP TABLE IF EXISTS player_match_stats;")
dbExecute(conn, "DROP TABLE IF EXISTS fixtures;")
dbExecute(conn, "DROP TABLE IF EXISTS players;")
dbExecute(conn, "DROP TABLE IF EXISTS teams;")
dbExecute(conn, "DROP TABLE IF EXISTS seasons;")
dbExecute(conn, "DROP TABLE IF EXISTS leagues;")

# Create tables in dependency order (parents first)
dbExecute(conn, "CREATE TABLE leagues (
  league_id INT PRIMARY KEY,
  name NVARCHAR(100),
  country NVARCHAR(100),
  logo NVARCHAR(255),
  flag NVARCHAR(255),
  type NVARCHAR(50)
);")

dbExecute(conn, "CREATE TABLE seasons (
  season_id INT IDENTITY(1,1) PRIMARY KEY,
  league_id INT,
  year INT,
  start_date DATE,
  end_date DATE,
  is_current BIT,
  FOREIGN KEY (league_id) REFERENCES leagues(league_id)
);")

dbExecute(conn, "CREATE TABLE teams (
  team_id INT PRIMARY KEY,
  name NVARCHAR(100),
  code NVARCHAR(10),
  country NVARCHAR(100),
  founded INT,
  is_national BIT,
  logo NVARCHAR(255)
);")

dbExecute(conn, "CREATE TABLE players (
  player_id INT,
  team_id INT,
  season INT,
  name NVARCHAR(100),
  firstname NVARCHAR(100),
  lastname NVARCHAR(100),
  age INT,
  birth_date DATE,
  birth_place NVARCHAR(100),
  birth_country NVARCHAR(100),
  nationality NVARCHAR(100),
  height NVARCHAR(10),
  weight NVARCHAR(10),
  injured BIT,
  photo NVARCHAR(255),
  PRIMARY KEY (player_id, team_id, season),
  FOREIGN KEY (team_id) REFERENCES teams(team_id)
);")

dbExecute(conn, "CREATE TABLE fixtures (
  fixture_id INT PRIMARY KEY,
  league_id INT,
  season_id INT,
  referee NVARCHAR(100),
  timezone NVARCHAR(50),
  date DATETIMEOFFSET,
  timestamp BIGINT,
  periods_first INT,
  periods_second INT,
  venue_id INT,
  venue_name NVARCHAR(100),
  venue_city NVARCHAR(100),
  status_long NVARCHAR(50),
  status_short NVARCHAR(10),
  status_elapsed INT,
  home_team_id INT,
  away_team_id INT,
  halftime_home INT,
  halftime_away INT,
  fulltime_home INT,
  fulltime_away INT,
  extratime_home INT,
  extratime_away INT,
  penalty_home INT,
  penalty_away INT,
  FOREIGN KEY (league_id) REFERENCES leagues(league_id),
  FOREIGN KEY (season_id) REFERENCES seasons(season_id),
  FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
  FOREIGN KEY (away_team_id) REFERENCES teams(team_id)
);")

dbExecute(conn, "CREATE TABLE events (
  event_id INT IDENTITY(1,1) PRIMARY KEY,
  fixture_id INT,
  team_id INT,
  player_id INT,
  season INT,  -- <-- Add this line
  elapsed INT,
  type NVARCHAR(50),
  detail NVARCHAR(100),
  comments NVARCHAR(255),
  FOREIGN KEY (fixture_id) REFERENCES fixtures(fixture_id),
  FOREIGN KEY (team_id) REFERENCES teams(team_id),
  FOREIGN KEY (player_id, team_id, season) REFERENCES players(player_id, team_id, season)
);")

dbExecute(conn, "CREATE TABLE player_match_stats (
  stats_id INT IDENTITY(1,1) PRIMARY KEY,
  fixture_id INT,
  team_id INT,
  player_id INT,
  season INT,
  game_rating DECIMAL(4,2),
  yellow_cards INT,
  red_cards INT,
  penalty_committed INT,
  penalty_missed INT,
  FOREIGN KEY (fixture_id) REFERENCES fixtures(fixture_id),
  FOREIGN KEY (team_id) REFERENCES teams(team_id),
  FOREIGN KEY (player_id, team_id, season) REFERENCES players(player_id, team_id, season)
);")

# Function to fetch and insert league data
fetch_leagues <- function() {
  url <- "https://api-football-v1.p.rapidapi.com/v2/leagues"
  response <- GET(url, add_headers(.headers = headers))
  leagues_data <- content(response, "parsed")
  
  for (league in leagues_data$api$leagues) {
    dbExecute(conn, "
      INSERT INTO leagues (league_id, name, country, logo, flag, type)
      VALUES (?, ?, ?, ?, ?, ?)",
      params = list(
        league$league_id,
        league$name,
        league$country,
        league$logo,
        league$flag,
        league$type
      )
    )
    
    # Insert season data
    dbExecute(conn, "
      INSERT INTO seasons (league_id, year, start_date, end_date, is_current)
      VALUES (?, ?, ?, ?, ?)",
      params = list(
        league$league_id,
        league$season,
        league$season_start,
        league$season_end,
        as.integer(league$is_current)
      )
    )
  }
}

# Function to fetch and insert team data
fetch_teams <- function(league_id, season) {
  url <- paste0("https://api-football-v1.p.rapidapi.com/v2/teams/league/", league_id)
  response <- GET(url, add_headers(.headers = headers))
  teams_data <- content(response, "parsed")
  
  for (team in teams_data$api$teams) {
    dbExecute(conn, "
      INSERT INTO teams (team_id, name, code, country, founded, is_national, logo)
      VALUES (?, ?, ?, ?, ?, ?, ?)",
      params = list(
        team$team_id,
        team$name,
        team$code,
        team$country,
        team$founded,
        as.integer(team$is_national),
        team$logo
      )
    )
  }
}

# Function to fetch and insert player data
fetch_players <- function(league_id, season) {
  url <- paste0("https://api-football-v1.p.rapidapi.com/v2/players/league/", league_id)
  response <- GET(url, add_headers(.headers = headers))
  players_data <- content(response, "parsed")
  
  for (player in players_data$api$players) {
    dbExecute(conn, "
      INSERT INTO players (player_id, team_id, season, name, firstname, lastname, age, birth_date, birth_place, 
                          birth_country, nationality, height, weight, injured, photo)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      params = list(
        player$player_id,
        player$team_id,
        player$season,
        player$player_name,
        player$firstname,
        player$lastname,
        player$age,
        player$birth_date,
        player$birth_place,
        player$birth_country,
        player$nationality,
        player$height,
        player$weight,
        as.integer(player$injured),
        player$photo
      )
    )
  }
}

# Function to fetch and insert fixture data
fetch_fixtures <- function(league_id, season) {
  url <- paste0("https://api-football-v1.p.rapidapi.com/v2/fixtures/league/", league_id)
  response <- GET(url, add_headers(.headers = headers))
  fixtures_data <- content(response, "parsed")
  
  for (fixture in fixtures_data$api$fixtures) {
    dbExecute(conn, "
      INSERT INTO fixtures (fixture_id, league_id, season_id, referee, timezone, date, timestamp,
                          periods_first, periods_second, venue_id, venue_name, venue_city,
                          status_long, status_short, status_elapsed,
                          home_team_id, away_team_id,
                          halftime_home, halftime_away, fulltime_home, fulltime_away,
                          extratime_home, extratime_away, penalty_home, penalty_away)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      params = list(
        fixture$fixture_id,
        league_id,
        season,
        fixture$referee,
        fixture$timezone,
        fixture$event_date,
        as.numeric(as.POSIXct(fixture$event_date)),
        fixture$firstHalfStart,
        fixture$secondHalfStart,
        fixture$venue_id,
        fixture$venue,
        fixture$venue_city,
        fixture$statusLong,
        fixture$statusShort,
        fixture$elapsed,
        fixture$homeTeam$team_id,
        fixture$awayTeam$team_id,
        fixture$score$halftime,
        fixture$score$halftime,
        fixture$score$fulltime,
        fixture$score$fulltime,
        fixture$score$extratime,
        fixture$score$extratime,
        fixture$score$penalty,
        fixture$score$penalty
      )
    )
  }
}

# Main execution
tryCatch({
  # Fetch and insert leagues and seasons
  fetch_leagues()
  
  # Get the current season for the Premier League (ID: 39)
  premier_league_id <- 39
  current_season <- 2024
  
  # Fetch and insert teams
  fetch_teams(premier_league_id, current_season)
  
  # Fetch and insert players
  fetch_players(premier_league_id, current_season)
  
  # Fetch and insert fixtures
  fetch_fixtures(premier_league_id, current_season)
  
  print("Database setup and data population completed successfully!")
}, error = function(e) {
  print(paste("Error:", e$message))
}, finally = {
  dbDisconnect(conn)
}) 