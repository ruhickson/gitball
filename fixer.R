fixture_id <- data_list[[j]]$parameters$fixture
team_id <- data_list[[j]]$response[[k]]$team$id
player_id <- data_list[[j]]$response[[k]]$player$id
player_name <- data_list[[j]]$response[[k]]$player$name
elapsed <- data_list[[j]]$response[[k]]$time$elapsed
type <- data_list[[j]]$response[[k]]$type
detail <- data_list[[j]]$response[[k]]$detail
comments <- data_list[[j]]$response[[k]]$comments


dbExecute(conn, "
  CREATE TABLE IF NOT EXISTS events (
    fixture_id INT,
    team_id INT,
    player_id INT,
    player_name TEXT,
    elapsed INT,
    type TEXT,
    detail TEXT,
    comments TEXT,
    PRIMARY KEY (fixture_id, player_id, elapsed)
  );
")


# Ensure necessary library is loaded
library(DBI)

# Iterate through j and k
for (j in seq_along(data_list)) {
  # Check if the response list is valid
  if (is.null(data_list[[j]]$response)) next
  
  for (k in seq_along(data_list[[j]]$response)) {
    # Extract data from the current fixture and response
    fixture_id <- data_list[[j]]$parameters$fixture
    team_id <- ifelse(length(data_list[[j]]$response[[k]]$team$id) == 1, data_list[[j]]$response[[k]]$team$id, NA)
    player_id <- ifelse(length(data_list[[j]]$response[[k]]$player$id) == 1, data_list[[j]]$response[[k]]$player$id, NA)
    player_name <- ifelse(length(data_list[[j]]$response[[k]]$player$name) == 1, data_list[[j]]$response[[k]]$player$name, NA)
    elapsed <- ifelse(length(data_list[[j]]$response[[k]]$time$elapsed) == 1, data_list[[j]]$response[[k]]$time$elapsed, NA)
    type <- ifelse(length(data_list[[j]]$response[[k]]$type) == 1, data_list[[j]]$response[[k]]$type, NA)
    detail <- ifelse(length(data_list[[j]]$response[[k]]$detail) == 1, data_list[[j]]$response[[k]]$detail, NA)
    comments <- ifelse(length(data_list[[j]]$response[[k]]$comments) == 1, data_list[[j]]$response[[k]]$comments, NA)
    
    # Insert data into the events table
    dbExecute(conn, "
      INSERT INTO events (fixture_id, team_id, player_id, player_name, elapsed, type, detail, comments)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      ON CONFLICT (fixture_id, player_id, elapsed) DO NOTHING",  # Handle potential duplicates
              params = list(fixture_id, team_id, player_id, player_name, elapsed, type, detail, comments)
    )
  }
}


#insert individual match events
match <- "https://v3.football.api-sports.io/fixtures/events?fixture=1208029"

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
