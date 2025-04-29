# Define the data to insert
fixture_id <- 1208026
team_id <- 789
player_id <- 4567
player_name <- "John Doe"
elapsed <- 45
type <- "Goal"
detail <- "Header"
comments <- "Well placed header"

# Insert data into the events table
dbExecute(con, "
  INSERT INTO events (fixture_id, team_id, player_id, player_name, elapsed, type, detail, comments)
  VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
          params = list(fixture_id, team_id, player_id, player_name, elapsed, type, detail, comments)
)