library(httr)
stats <- "https://v3.football.api-sports.io/fixtures/players?fixture=1208029"
response <- GET(stats, headers)  # Replace YOUR_API_KEY with your actual API key
players_stats <- content(response, "parsed")

fixture_id <- players_stats$parameters$fixture
team_id <- players_stats$response[[j]]$team$id
player_id <- players_stats$response[[j]]$players[[k]]$player$id
game_rating <- players_stats$response[[j]]$players[[k]]$statistics[[1]]$games$rating
yellow_cards <- players_stats$response[[j]]$players[[k]]$statistics[[1]]$cards$yellow
red_cards <- players_stats$response[[j]]$players[[k]]$statistics[[1]]$cards$red
penalty_committed <- players_stats$response[[j]]$players[[k]]$statistics[[1]]$penalty$commited
penalty_missed <- players_stats$response[[j]]$players[[k]]$statistics[[1]]$penalty$missed


# Ensure single values or NULL for each parameter
normalize_value <- function(x) {
  if (length(x) == 0 || is.null(x)) {
    return(NULL)
  } else {
    return(x)
  }
}



library(DBI)

# Assuming 'con' is your active PostgreSQL connection
dbExecute(conn, "
  CREATE TABLE IF NOT EXISTS player_match_stats (
    fixture_id INT,
    team_id INT,
    player_id INT,
    game_rating DECIMAL(4,2),
    yellow_cards INT,
    red_cards INT,
    penalty_committed INT,
    penalty_missed INT
  );
")

# Function to ensure the value is either a single value or NULL
normalize_value <- function(x) {
  if (length(x) == 0 || is.null(x) || is.na(x)) {
    return(NULL)
  } else {
    return(x)
  }
}

# Initialize an empty list to collect the data
player_match_stats_list <- list()

# Iterate over j (team index) and k (player index)
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

replace_null_with_zero <- function(x) {
  if (is.null(x)) {
    return(0)
  } else {
    return(x)
  }
}

# Replace all NULLs with 0 in the player_match_stats_list
player_match_stats_list <- lapply(player_match_stats_list, function(record) {
  lapply(record, replace_null_with_zero)
})


# Insert data into the database
# Insert data into the database, coalescing NULL values to 0
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



