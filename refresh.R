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

# Connect to the database
conn <- dbConnect(odbc::odbc(), .connection_string = conn_string)

# API configuration
api_host <- Sys.getenv("API_HOST")
api_key <- Sys.getenv("API_KEY")

# Set up the headers including the API key and host
headers <- c(
  `x-rapidapi-key` = api_key,
  `x-rapidapi-host` = api_host
)

normalize_value <- function(x) {
  if (length(x) == 0 || is.null(x)) {
    return(NULL)
  } else {
    return(x)
  }
}
replace_null_with_zero <- function(x) {
  if (is.null(x)) {
    return(0)
  } else {
    return(x)
  }
}

# Update fixtures
fixture_id <- 1208050

fixture_update <- paste0("https://v3.football.api-sports.io/fixtures?id=",fixture_id)
response <- GET(fixture_update, headers)
response_json <- content(response, "parsed")
for (i in seq_along(response_json$response)) {
  fixture <- response_json$response[[i]]$fixture
  teams <- response_json$response[[i]]$teams
  score <- response_json$response[[i]]$score
  
  # Extract data with checks to ensure scalars
  id <- ifelse(length(fixture$id) == 1, fixture$id, NA)
  referee <- ifelse(length(fixture$referee) == 1, fixture$referee, NA)
  timezone <- ifelse(length(fixture$timezone) == 1, fixture$timezone, NA)
  date <- ifelse(length(fixture$date) == 1, fixture$date, NA)
  timestamp <- ifelse(length(fixture$timestamp) == 1, fixture$timestamp, NA)
  periods_first <- ifelse(length(fixture$periods$first) == 1, fixture$periods$first, NA)
  periods_second <- ifelse(length(fixture$periods$second) == 1, fixture$periods$second, NA)
  venue_id <- ifelse(length(fixture$venue$id) == 1, fixture$venue$id, NA)
  venue_name <- ifelse(length(fixture$venue$name) == 1, fixture$venue$name, NA)
  venue_city <- ifelse(length(fixture$venue$city) == 1, fixture$venue$city, NA)
  status_long <- ifelse(length(fixture$status$long) == 1, fixture$status$long, NA)
  status_short <- ifelse(length(fixture$status$short) == 1, fixture$status$short, NA)
  status_elapsed <- ifelse(length(fixture$status$elapsed) == 1, fixture$status$elapsed, NA)
  
  # Home team data
  home_team_id <- ifelse(length(teams$home$id) == 1, teams$home$id, NA)
  home_team_name <- ifelse(length(teams$home$name) == 1, teams$home$name, NA)
  home_team_logo <- ifelse(length(teams$home$logo) == 1, teams$home$logo, NA)
  home_team_winner <- ifelse(length(teams$home$winner) == 1, teams$home$winner, NA)
  
  # Away team data
  away_team_id <- ifelse(length(teams$away$id) == 1, teams$away$id, NA)
  away_team_name <- ifelse(length(teams$away$name) == 1, teams$away$name, NA)
  away_team_logo <- ifelse(length(teams$away$logo) == 1, teams$away$logo, NA)
  away_team_winner <- ifelse(length(teams$away$winner) == 1, teams$away$winner, NA)
  
  # Scores
  halftime_home <- ifelse(length(score$halftime$home) == 1, score$halftime$home, NA)
  halftime_away <- ifelse(length(score$halftime$away) == 1, score$halftime$away, NA)
  fulltime_home <- ifelse(length(score$fulltime$home) == 1, score$fulltime$home, NA)
  fulltime_away <- ifelse(length(score$fulltime$away) == 1, score$fulltime$away, NA)
  extratime_home <- ifelse(length(score$extratime$home) == 1, score$extratime$home, NA)
  extratime_away <- ifelse(length(score$extratime$away) == 1, score$extratime$away, NA)
  penalty_home <- ifelse(length(score$penalty$home) == 1, score$penalty$home, NA)
  penalty_away <- ifelse(length(score$penalty$away) == 1, score$penalty$away, NA)
  
  # Insert data into the fixtures table
  dbExecute(conn, "
  UPDATE fixtures
  SET
    referee = $2,
    timezone = $3,
    date = $4,
    timestamp = $5,
    periods_first = $6,
    periods_second = $7,
    venue_id = $8,
    venue_name = $9,
    venue_city = $10,
    status_long = $11,
    status_short = $12,
    status_elapsed = $13,
    home_team_id = $14,
    home_team_name = $15,
    home_team_logo = $16,
    home_team_winner = $17,
    away_team_id = $18,
    away_team_name = $19,
    away_team_logo = $20,
    away_team_winner = $21,
    halftime_home = $22,
    halftime_away = $23,
    fulltime_home = $24,
    fulltime_away = $25,
    extratime_home = $26,
    extratime_away = $27,
    penalty_home = $28,
    penalty_away = $29
  WHERE id = $1",
            params = list(fixture_id, referee, timezone, date, timestamp, periods_first, periods_second, venue_id, venue_name, venue_city, status_long, status_short, status_elapsed,
                          home_team_id, home_team_name, home_team_logo, home_team_winner,
                          away_team_id, away_team_name, away_team_logo, away_team_winner,
                          halftime_home, halftime_away, fulltime_home, fulltime_away, extratime_home, extratime_away, penalty_home, penalty_away)
  )
  
}

# Add Events
#insert individual match events
match <- paste0("https://v3.football.api-sports.io/fixtures/events?fixture=",fixture_id)
response <- GET(match, headers)  # Replace YOUR_API_KEY with your actual API key
data_insert <- content(response, "parsed")

length(data_insert$response)

for (k in seq_along(data_insert$response)) {
  fixture_id <- data_insert$parameters$fixture
  team_id <- ifelse(length(data_insert$response[[k]]$team$id) == 1, data_insert$response[[k]]$team$id, NA)
  player_id <- ifelse(length(data_insert$response[[k]]$player$id) == 1, data_insert$response[[k]]$player$id, NA)
  player_name <- ifelse(length(data_insert$response[[k]]$player$name) == 1, data_insert$response[[k]]$player$name, NA)
  elapsed <- ifelse(length(data_insert$response[[k]]$time$elapsed) == 1, data_insert$response[[k]]$time$elapsed, NA)
  type <- ifelse(length(data_insert$response[[k]]$type) == 1, data_insert$response[[k]]$type, NA)
  detail <- ifelse(length(data_insert$response[[k]]$detail) == 1, data_insert$response[[k]]$detail, NA)
  comments <- ifelse(length(data_insert$response[[k]]$comments) == 1, data_insert$response[[k]]$comments, NA)
  
  # Insert data into the events table
  dbExecute(conn, "
        INSERT INTO events (fixture_id, team_id, player_id, player_name, elapsed, type, detail, comments)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT (fixture_id, player_id, elapsed) DO NOTHING",  # Handle potential duplicates
            params = list(fixture_id, team_id, player_id, player_name, elapsed, type, detail, comments)
  )
}

# Add Player Stats
stats <- paste0("https://v3.football.api-sports.io/fixtures/players?fixture=",fixture_id)
response <- GET(stats, headers)  # Replace YOUR_API_KEY with your actual API key
players_stats <- content(response, "parsed")

player_match_stats_list <- list()

for (j in seq_along(players_stats$response)) {
  for (k in seq_along(players_stats$response[[j]]$players)) {
    # Collect and normalize the data
    fixture_id <- normalize_value(players_stats$parameters$fixture)
    team_id <- normalize_value(players_stats$response[[j]]$team$id)
    player_id <- normalize_value(players_stats$response[[j]]$players[[k]]$player$id)
    game_rating <- normalize_value(players_stats$response[[j]]$players[[k]]$statistics[[1]]$games$rating)
    yellow_cards <- normalize_value(players_stats$response[[j]]$players[[k]]$statistics[[1]]$cards$yellow)
    red_cards <- normalize_value(players_stats$response[[j]]$players[[k]]$statistics[[1]]$cards$red)
    penalty_committed <- normalize_value(players_stats$response[[j]]$players[[k]]$statistics[[1]]$penalty$commited)
    penalty_missed <- normalize_value(players_stats$response[[j]]$players[[k]]$statistics[[1]]$penalty$missed)
    
    # Debugging: Print the values to ensure they are correct
    print(list(
      fixture_id = fixture_id,
      team_id = team_id,
      player_id = player_id,
      game_rating = game_rating,
      yellow_cards = yellow_cards,
      red_cards = red_cards,
      penalty_committed = penalty_committed,
      penalty_missed = penalty_missed
    ))
    
    # Append the data as a list to the player_match_stats_list
    player_match_stats_list[[length(player_match_stats_list) + 1]] <- list(
      fixture_id = fixture_id,
      team_id = team_id,
      player_id = player_id,
      game_rating = game_rating,
      yellow_cards = yellow_cards,
      red_cards = red_cards,
      penalty_committed = penalty_committed,
      penalty_missed = penalty_missed
    )
  }
}

player_match_stats_list <- lapply(player_match_stats_list, function(record) {
  lapply(record, replace_null_with_zero)
})

for (record in player_match_stats_list) {
  dbExecute(conn, "
    INSERT INTO player_match_stats (
      fixture_id, team_id, player_id, game_rating,
      yellow_cards, red_cards, penalty_committed, penalty_missed
    ) VALUES (
      COALESCE($1, 0), 
      COALESCE($2, 0), 
      COALESCE($3, 0), 
      COALESCE(ROUND($4,2), 0), 
      COALESCE($5, 0), 
      COALESCE($6, 0), 
      COALESCE($7, 0), 
      COALESCE($8, 0)
    )",
            params = list(
              record$fixture_id, 
              record$team_id, 
              record$player_id, 
              as.numeric(record$game_rating), 
              as.integer(record$yellow_cards), 
              as.integer(record$red_cards), 
              as.integer(record$penalty_committed), 
              as.integer(record$penalty_missed)
            )
  )
}

# Recalculate Leaderboards

dbExecute(conn,"DROP TABLE twatlog;")
dbExecute(conn,"CREATE TABLE twatlog AS (SELECT * FROM events);")
dbExecute(conn,"ALTER TABLE twatlog ADD COLUMN points INT;")

dbExecute(conn,"UPDATE twatlog
SET points = 8
WHERE detail = 'Yellow Card' AND comments = 'Foul';")

dbExecute(conn,"UPDATE twatlog
SET points = 14
WHERE detail = 'Yellow Card' AND comments != 'Foul';")

dbExecute(conn,"UPDATE twatlog
SET points = 2
WHERE detail LIKE 'Substitution%';")

dbExecute(conn,"UPDATE twatlog
SET points = 6
WHERE detail LIKE 'Substitution%' AND elapsed < 20;")

dbExecute(conn,"UPDATE twatlog
SET points = -4
WHERE detail = 'Normal Goal' OR detail = 'Penalty';")

dbExecute(conn,"UPDATE twatlog
SET points = 12
WHERE detail = 'Own Goal';")

dbExecute(conn,"UPDATE twatlog
SET points = 12
WHERE detail = 'Spectacular blunder leading to goal';")

dbExecute(conn,"UPDATE twatlog
SET points = 5
WHERE detail = 'Goal cancelled';")

dbExecute(conn,"UPDATE twatlog
SET points = 5
WHERE detail = 'Penalty cancelled';")

dbExecute(conn,"UPDATE twatlog
SET points = 5
WHERE detail = 'Goal Disallowed - offside';")

dbExecute(conn,"UPDATE twatlog
SET points = 4
WHERE detail = 'Conceded injury time winner or equaliser';")

dbExecute(conn,"UPDATE twatlog
SET points = 10
WHERE detail = 'Failed to win a game that they were leading by 2 or more goals';")

dbExecute(conn,"DROP TABLE leaderboard;")
dbExecute(conn,"CREATE TABLE leaderboard as (
  select name, sum(points) as total from
  (
    select player_id, sum(points) as points from twatlog
    group by 1
    union
    select player_id, sum(prickpoints) as points from
    (select distinct player_id, team_id, home_team_id, fulltime_home, away_team_id, fulltime_away
      ,case when team_id = home_team_id then fulltime_away*2
      when team_id = away_team_id then fulltime_home*2
      else 0 end as prickpoints
      from player_match_stats pms
      join fixtures f on pms.fixture_id = f.id
      where game_rating > 0)
    group by 1
  ) points_total
  join players on points_total.player_id = players.id
  group by 1
  order by 2 desc
);")
