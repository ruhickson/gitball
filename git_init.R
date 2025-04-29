# git_init.R
# Populate all tables in the database using API-Football (direct key, not RapidAPI)
library(odbc)
library(DBI)
library(httr)
library(jsonlite)

# Load environment variables
readRenviron(".Renv")

# Database connection parameters
db_host <- Sys.getenv("DB_HOST")
db_port <- as.integer(Sys.getenv("DB_PORT"))
db_name <- Sys.getenv("DB_NAME")
client_id <- Sys.getenv("AZURE_CLIENT_ID")
client_secret <- Sys.getenv("AZURE_CLIENT_SECRET")

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
conn <- dbConnect(
  odbc::odbc(),
  .connection_string = conn_string,
  timeout = 10
)

# API-Football direct key usage
api_key <- Sys.getenv("API_KEY")
headers <- c(`x-apisports-key` = api_key)

# --- Leagues and Seasons ---
leagues_url <- "https://v3.football.api-sports.io/leagues"
leagues_resp <- GET(leagues_url, add_headers(.headers = headers))
leagues_data <- content(leagues_resp, "parsed")

for (league in leagues_data$response) {
  dbExecute(conn, "INSERT INTO leagues (league_id, name, country, logo, flag, type) VALUES (?, ?, ?, ?, ?, ?)",
    params = list(
      ifelse(!is.null(league$league$id), league$league$id, NA),
      ifelse(!is.null(league$league$name), league$league$name, NA),
      ifelse(!is.null(league$country$name), league$country$name, NA),
      ifelse(!is.null(league$league$logo), league$league$logo, NA),
      ifelse(!is.null(league$country$flag), league$country$flag, NA),
      ifelse(!is.null(league$league$type), league$league$type, NA)
    )
  )
  # Insert all seasons for this league
  for (season in league$seasons) {
    dbExecute(conn, "INSERT INTO seasons (league_id, year, start_date, end_date, is_current) VALUES (?, ?, ?, ?, ?)",
      params = list(
        ifelse(!is.null(league$league$id), league$league$id, NA),
        ifelse(!is.null(season$year), season$year, NA),
        ifelse(!is.null(season$start), season$start, NA),
        ifelse(!is.null(season$end), season$end, NA),
        ifelse(!is.null(season$current), as.integer(season$current), NA)
      )
    )
  }
}

# --- Teams ---
# Example: Premier League 2024 (league_id = 39, season = 2024)
premier_league_id <- 39
current_season <- 2024
teams_url <- paste0("https://v3.football.api-sports.io/teams?league=", premier_league_id, "&season=", current_season)
teams_resp <- GET(teams_url, add_headers(.headers = headers))
teams_data <- content(teams_resp, "parsed")

for (team in teams_data$response) {
  dbExecute(conn, "INSERT INTO teams (team_id, name, code, country, founded, is_national, logo) VALUES (?, ?, ?, ?, ?, ?, ?)",
    params = list(
      team$team$id,
      team$team$name,
      team$team$code,
      team$team$country,
      team$team$founded,
      as.integer(team$team$national),
      team$team$logo
    )
  )
}

# --- Players ---
# API-Football paginates players, so loop through pages
i <- 1
repeat {
  players_url <- paste0("https://v3.football.api-sports.io/players?league=", premier_league_id, "&season=", current_season, "&page=", i)
  players_resp <- GET(players_url, add_headers(.headers = headers))
  players_data <- content(players_resp, "parsed")
  if (length(players_data$response) == 0) break
  for (player in players_data$response) {
    dbExecute(conn, "INSERT INTO players (player_id, name, firstname, lastname, age, birth_date, birth_place, birth_country, nationality, height, weight, injured, photo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      params = list(
        player$player$id,
        player$player$name,
        player$player$firstname,
        player$player$lastname,
        player$player$age,
        player$player$birth$date,
        player$player$birth$place,
        player$player$birth$country,
        player$player$nationality,
        player$player$height,
        player$player$weight,
        as.integer(player$player$injured),
        player$player$photo
      )
    )
  }
  i <- i + 1
}

# --- Fixtures ---
fixtures_url <- paste0("https://v3.football.api-sports.io/fixtures?league=", premier_league_id, "&season=", current_season)
fixtures_resp <- GET(fixtures_url, add_headers(.headers = headers))
fixtures_data <- content(fixtures_resp, "parsed")

for (fixture in fixtures_data$response) {
  dbExecute(conn, "INSERT INTO fixtures (fixture_id, league_id, season_id, referee, timezone, date, timestamp, periods_first, periods_second, venue_id, venue_name, venue_city, status_long, status_short, status_elapsed, home_team_id, away_team_id, halftime_home, halftime_away, fulltime_home, fulltime_away, extratime_home, extratime_away, penalty_home, penalty_away) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
    params = list(
      fixture$fixture$id,
      fixture$league$id,
      fixture$league$season,
      fixture$fixture$referee,
      fixture$fixture$timezone,
      fixture$fixture$date,
      fixture$fixture$timestamp,
      fixture$periods$first,
      fixture$periods$second,
      fixture$fixture$venue$id,
      fixture$fixture$venue$name,
      fixture$fixture$venue$city,
      fixture$status$long,
      fixture$status$short,
      fixture$status$elapsed,
      fixture$teams$home$id,
      fixture$teams$away$id,
      fixture$score$halftime$home,
      fixture$score$halftime$away,
      fixture$score$fulltime$home,
      fixture$score$fulltime$away,
      fixture$score$extratime$home,
      fixture$score$extratime$away,
      fixture$score$penalty$home,
      fixture$score$penalty$away
    )
  )
}

# --- Events and Player Match Stats ---
# For each fixture, fetch events and player stats
for (fixture in fixtures_data$response) {
  fixture_id <- fixture$fixture$id
  # Events
  events_url <- paste0("https://v3.football.api-sports.io/fixtures/events?fixture=", fixture_id)
  events_resp <- GET(events_url, add_headers(.headers = headers))
  events_data <- content(events_resp, "parsed")
  for (event in events_data$response) {
    dbExecute(conn, "INSERT INTO events (fixture_id, team_id, player_id, elapsed, type, detail, comments) VALUES (?, ?, ?, ?, ?, ?, ?)",
      params = list(
        event$fixture,
        event$team$id,
        event$player$id,
        event$time$elapsed,
        event$type,
        event$detail,
        event$comments
      )
    )
  }
  # Player Match Stats
  stats_url <- paste0("https://v3.football.api-sports.io/fixtures/players?fixture=", fixture_id)
  stats_resp <- GET(stats_url, add_headers(.headers = headers))
  stats_data <- content(stats_resp, "parsed")
  for (stat in stats_data$response) {
    dbExecute(conn, "INSERT INTO player_match_stats (fixture_id, team_id, player_id, game_rating, yellow_cards, red_cards, penalty_committed, penalty_missed) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      params = list(
        fixture_id,
        stat$team$id,
        stat$players[[1]]$player$id,
        as.numeric(stat$players[[1]]$statistics$games$rating),
        stat$players[[1]]$statistics$cards$yellow,
        stat$players[[1]]$statistics$cards$red,
        stat$players[[1]]$statistics$penalty$commited,
        stat$players[[1]]$statistics$penalty$missed
      )
    )
  }
}

dbDisconnect(conn)
cat("Database population completed successfully!\n") 