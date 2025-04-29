# Load necessary libraries
# install.packages("odbc")
# install.packages("DBI")
library(odbc)
library(DBI)
library(httr)

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
  "Authentication=ActiveDirectoryServicePrincipal;",
  "UID=", Sys.getenv("AZURE_CLIENT_ID"), ";",
  "PWD=", Sys.getenv("AZURE_CLIENT_SECRET")
)

# Create a connection
conn <- dbConnect(odbc::odbc(), .connection_string = conn_string)

# Check connection
if (!dbIsValid(conn)) {
  stop("Failed to connect to the database!")
}

# Example query: Fetch all records from the matches table
#query <- "SELECT '1';"
#result <- dbGetQuery(conn, query)
# Print the result
#print(result)
# Close the connection
#dbDisconnect(conn)

url <- "https://v3.football.api-sports.io/leagues"

# API configuration
api_host <- Sys.getenv("API_HOST")
api_key <- Sys.getenv("API_KEY")

# Set up the headers including the API key and host
headers <- c(
  `x-rapidapi-key` = api_key,
  `x-rapidapi-host` = api_host
)

# Make the GET request
response <- GET(url, add_headers(.headers = headers))

# Print the status code
print(paste("Status code:", status_code(response)))

# Print the response content as text
response_text <- content(response, "text")
response_json <- content(response, "parsed")
print(response_json)

response_text
response_json


premierleague2024 <- "https://v3.football.api-sports.io/leagues?id=39"
response <- GET(premierleague2024, add_headers(.headers = headers))
response_json <- content(response, "parsed")
pl2024 <- response_json

epl2024 <- "https://v3.football.api-sports.io/teams?league=39&season=2024"
response <- GET(epl2024, add_headers(.headers = headers))
response_json <- content(response, "parsed")
epl_teams <- response_json

epl_players_2024 <- "https://v3.football.api-sports.io/players?league=39&season=2024"
response <- GET(epl_players_2024, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp1 <- response_json
response_json$paging

epl_players_2024 <- "https://v3.football.api-sports.io/players?league=39&season=2024&page=2"
response <- GET(epl_players_2024, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp2 <- response_json
eplp2$paging

response_json


epl_players_2024_1 <- "https://v3.football.api-sports.io/players?league=39&season=2024&page=1"
epl_players_2024_2 <- "https://v3.football.api-sports.io/players?league=39&season=2024&page=2"
epl_players_2024_3 <- "https://v3.football.api-sports.io/players?league=39&season=2024&page=3"
epl_players_2024_4 <- "https://v3.football.api-sports.io/players?league=39&season=2024&page=4"
epl_players_2024_5 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=5'
epl_players_2024_6 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=6'
epl_players_2024_7 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=7'
epl_players_2024_8 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=8'
epl_players_2024_9 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=9'
epl_players_2024_10 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=10'
epl_players_2024_11 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=11'
epl_players_2024_12 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=12'
epl_players_2024_13 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=13'
epl_players_2024_14 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=14'
epl_players_2024_15 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=15'
epl_players_2024_16 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=16'
epl_players_2024_17 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=17'
epl_players_2024_18 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=18'
epl_players_2024_19 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=19'
epl_players_2024_20 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=20'
epl_players_2024_21 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=21'
epl_players_2024_22 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=22'
epl_players_2024_23 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=23'
epl_players_2024_24 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=24'
epl_players_2024_25 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=25'
epl_players_2024_26 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=26'
epl_players_2024_27 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=27'
epl_players_2024_28 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=28'
epl_players_2024_29 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=29'
epl_players_2024_30 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=30'
epl_players_2024_31 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=31'
epl_players_2024_32 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=32'
epl_players_2024_33 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=33'
epl_players_2024_34 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=34'
epl_players_2024_35 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=35'
epl_players_2024_36 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=36'
epl_players_2024_37 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=37'
epl_players_2024_38 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=38'
epl_players_2024_39 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=39'
epl_players_2024_40 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=40'
epl_players_2024_41 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=41'
epl_players_2024_42 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=42'
epl_players_2024_43 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=43'
epl_players_2024_44 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=44'
epl_players_2024_45 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=45'
epl_players_2024_46 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=46'
epl_players_2024_47 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=47'
epl_players_2024_48 <- 'https://v3.football.api-sports.io/players?league=39&season=2024&page=48'

response <- GET(epl_players_2024_1, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp1 <- response_json
response <- GET(epl_players_2024_2, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp2 <- response_json
response <- GET(epl_players_2024_3, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp3 <- response_json
response <- GET(epl_players_2024_4, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp4 <- response_json
response <- GET(epl_players_2024_5, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp5 <- response_json
response <- GET(epl_players_2024_6, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp6 <- response_json
response <- GET(epl_players_2024_2, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp7 <- response_json
response <- GET(epl_players_2024_8, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp8 <- response_json
response <- GET(epl_players_2024_9, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp9 <- response_json
response <- GET(epl_players_2024_10, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp10 <- response_json
response <- GET(epl_players_2024_11, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp11 <- response_json
response <- GET(epl_players_2024_12, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp12 <- response_json
response <- GET(epl_players_2024_13, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp13 <- response_json
response <- GET(epl_players_2024_14, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp14 <- response_json
response <- GET(epl_players_2024_15, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp15 <- response_json
response <- GET(epl_players_2024_16, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp16 <- response_json
response <- GET(epl_players_2024_17, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp17 <- response_json
response <- GET(epl_players_2024_18, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp18 <- response_json
response <- GET(epl_players_2024_19, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp19 <- response_json
response <- GET(epl_players_2024_20, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp20 <- response_json
response <- GET(epl_players_2024_21, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp21 <- response_json
response <- GET(epl_players_2024_22, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp22 <- response_json
response <- GET(epl_players_2024_23, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp23 <- response_json
response <- GET(epl_players_2024_24, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp24 <- response_json
response <- GET(epl_players_2024_25, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp25 <- response_json
response <- GET(epl_players_2024_26, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp26 <- response_json
response <- GET(epl_players_2024_27, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp27 <- response_json
response <- GET(epl_players_2024_28, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp28 <- response_json
response <- GET(epl_players_2024_29, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp29 <- response_json
response <- GET(epl_players_2024_30, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp30 <- response_json
response <- GET(epl_players_2024_31, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp31 <- response_json
response <- GET(epl_players_2024_32, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp32 <- response_json
response <- GET(epl_players_2024_33, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp33 <- response_json
response <- GET(epl_players_2024_34, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp34 <- response_json
response <- GET(epl_players_2024_35, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp35 <- response_json
response <- GET(epl_players_2024_36, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp36 <- response_json
response <- GET(epl_players_2024_37, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp37 <- response_json
response <- GET(epl_players_2024_38, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp38 <- response_json
response <- GET(epl_players_2024_39, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp39 <- response_json
response <- GET(epl_players_2024_40, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp40 <- response_json
response <- GET(epl_players_2024_41, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp41 <- response_json
response <- GET(epl_players_2024_42, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp42 <- response_json
response <- GET(epl_players_2024_43, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp43 <- response_json
response <- GET(epl_players_2024_44, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp44 <- response_json
response <- GET(epl_players_2024_45, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp45 <- response_json
response <- GET(epl_players_2024_46, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp46 <- response_json
response <- GET(epl_players_2024_47, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp47 <- response_json
response <- GET(epl_players_2024_48, add_headers(.headers = headers))
response_json <- content(response, "parsed")
eplp48 <- response_json


eplp48$paging

eplp48
eplp39$paging
eplp14$paging


eplp_list[[1]]$response[[1]]$player

# Combine them into a single dataframe
combined_df <- bind_rows(eplp_list)
library(dplyr)
library(purrr)


length(eplp1$response)
eplp1$response[[1]]$player



# Create a list of all the dataframes
eplp_list <- mget(paste0("eplp", 1:48))

# Initialize an empty list to store the results
result_list <- list()

# Iterate over j from 1 to 48
for (j in 1:48) {
  # Iterate over k from 1 to 20
  for (k in 1:20) {
    # Access the player data and store it in the list
    result_list[[paste0("j", j, "_k", k)]] <- eplp_list[[j]]$response[[k]]$player
  }
}
j

# Optionally, combine the list into a dataframe if needed
combined_df <- do.call(rbind, result_list)

eplp_list[[j]]$response[[k]]$player

str(result_list[[1]])



# Drop the table if it already exists
dbExecute(conn, "DROP TABLE IF EXISTS players;")

# Recreate the table without a primary key
dbExecute(conn, "
  CREATE TABLE players (
    id INT,
    name TEXT,
    firstname TEXT,
    lastname TEXT,
    age INT,
    birth_date DATE,
    birth_place TEXT,
    birth_country TEXT,
    nationality TEXT,
    height TEXT,
    weight TEXT,
    injured BOOLEAN,
    photo TEXT
  );
")


for (i in 1:121) {
  player <- result_list[[i]]
  
  # Extract and ensure all values are scalars or properly handled if NULL
  id <- ifelse(length(player$id) == 1, player$id, NA)
  name <- ifelse(length(player$name) == 1, player$name, NA)
  firstname <- ifelse(length(player$firstname) == 1, player$firstname, NA)
  lastname <- ifelse(length(player$lastname) == 1, player$lastname, NA)
  age <- ifelse(length(player$age) == 1, player$age, NA)
  
  birth_date <- ifelse(is.null(player$birth$date) || length(player$birth$date) != 1, NA, player$birth$date)
  birth_place <- ifelse(is.null(player$birth$place) || length(player$birth$place) != 1, NA, player$birth$place)
  birth_country <- ifelse(is.null(player$birth$country) || length(player$birth$country) != 1, NA, player$birth$country)
  
  nationality <- ifelse(length(player$nationality) == 1, player$nationality, NA)
  height <- ifelse(length(player$height) == 1, player$height, NA)
  weight <- ifelse(length(player$weight) == 1, player$weight, NA)
  injured <- ifelse(length(player$injured) == 1, player$injured, NA)
  photo <- ifelse(length(player$photo) == 1, player$photo, NA)
  
  # Insert into the PostgreSQL table
  dbExecute(conn, "
    INSERT INTO players (id, name, firstname, lastname, age, birth_date, birth_place, birth_country, nationality, height, weight, injured, photo)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)",
            params = list(id, name, firstname, lastname, age, birth_date, birth_place, birth_country, nationality, height, weight, injured, photo)
  )
}

premierleague2024
epl2024
str(epl_teams$response[[1]]$team)

dbExecute(conn, "
  CREATE TABLE IF NOT EXISTS teams (
    id INT,
    name TEXT,
    code TEXT,
    country TEXT,
    founded INT,
    national BOOLEAN,
    logo TEXT
  );
")


# Loop through each team entry in epl_teams$response
for (i in seq_along(epl_teams$response)) {
  team <- epl_teams$response[[i]]$team
  
  # Extract data
  id <- team$id
  name <- team$name
  code <- team$code
  country <- team$country
  founded <- team$founded
  national <- team$national
  logo <- team$logo
  
  # Insert data into the teams table
  dbExecute(conn, "
    INSERT INTO teams (id, name, code, country, founded, national, logo)
    VALUES ($1, $2, $3, $4, $5, $6, $7)",
            params = list(id, name, code, country, founded, national, logo)
  )
}



gameweeks <- "https://v3.football.api-sports.io/fixtures/rounds?season=2024&league=39"
response <- GET(gameweeks, add_headers(.headers = headers))
response_json <- content(response, "parsed")
response_json$response[[1]]
gw <- response_json

fixtures2024 <- "https://v3.football.api-sports.io/fixtures?league=39&season=2024"
response <- GET(fixtures2024, add_headers(.headers = headers))
response_json <- content(response, "parsed")

str(response_json$response[[1]]$fixture)


dbExecute(conn, "
  CREATE TABLE IF NOT EXISTS fixtures (
    id INT PRIMARY KEY,
    referee TEXT,
    timezone TEXT,
    date TIMESTAMPTZ,
    timestamp INT,
    periods_first INT,
    periods_second INT,
    venue_id INT,
    venue_name TEXT,
    venue_city TEXT,
    status_long TEXT,
    status_short TEXT,
    status_elapsed INT,
    
    -- Home team data
    home_team_id INT,
    home_team_name TEXT,
    home_team_logo TEXT,
    home_team_winner BOOLEAN,
    
    -- Away team data
    away_team_id INT,
    away_team_name TEXT,
    away_team_logo TEXT,
    away_team_winner BOOLEAN,
    
    -- Scores
    halftime_home INT,
    halftime_away INT,
    fulltime_home INT,
    fulltime_away INT,
    extratime_home INT,
    extratime_away INT,
    penalty_home INT,
    penalty_away INT
  );
")


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
    INSERT INTO fixtures (id, referee, timezone, date, timestamp, periods_first, periods_second, venue_id, venue_name, venue_city, status_long, status_short, status_elapsed,
                          home_team_id, home_team_name, home_team_logo, home_team_winner,
                          away_team_id, away_team_name, away_team_logo, away_team_winner,
                          halftime_home, halftime_away, fulltime_home, fulltime_away, extratime_home, extratime_away, penalty_home, penalty_away)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
            $14, $15, $16, $17,
            $18, $19, $20, $21,
            $22, $23, $24, $25, $26, $27, $28, $29)",
            params = list(id, referee, timezone, date, timestamp, periods_first, periods_second, venue_id, venue_name, venue_city, status_long, status_short, status_elapsed,
                          home_team_id, home_team_name, home_team_logo, home_team_winner,
                          away_team_id, away_team_name, away_team_logo, away_team_winner,
                          halftime_home, halftime_away, fulltime_home, fulltime_away, extratime_home, extratime_away, penalty_home, penalty_away)
  )
}


get_fix <- dbGetQuery(conn,"select id from fixtures
where status_short = 'FT'")

get_fix

"https://v3.football.api-sports.io/fixtures/events?fixture=1208021"

base_url <- "https://v3.football.api-sports.io/fixtures/events?fixture="

# Iterate through the vector and generate URLs
urls <- sapply(get_fix, function(fixture_id) {
  paste0(base_url, fixture_id)
})

# Print URLs to verify
print(urls)

# If you want to fetch data for each URL
library(httr)

# Define a function to fetch data from a URL
fetch_data <- function(url) {
  response <- GET(url, add_headers(.headers = headers))  # Replace YOUR_API_KEY with your actual API key
  content(response, "parsed")
}

# Iterate through URLs and fetch data
data_list <- lapply(urls, fetch_data)

# Check the structure of the fetched data
print(data_list)


fixture_id <- data_list[[1]]$parameters$fixture
team_id <- data_list[[1]]$response[[1]]$team$id
player_id <- data_list[[1]]$response[[1]]$player$id
player_name <- data_list[[1]]$response[[1]]$player$name
elapsed <- data_list[[1]]$response[[1]]$time$elapsed
type <- data_list[[1]]$response[[1]]$type
detail <- data_list[[1]]$response[[1]]$detail
comments <- data_list[[1]]$response[[1]]$comments

# Define the base URL for EPL players 2024
base_url <- "https://v3.football.api-sports.io/players?league=39&season=2024&page="

# Create a list to store all responses
eplp_list <- vector("list", 48)

# Fetch all 48 pages
for (i in 1:48) {
  url <- paste0(base_url, i)
  response <- GET(url, add_headers(.headers = headers))
  if (status_code(response) != 200) {
    warning(paste("Failed to fetch page", i, "Status:", status_code(response)))
    eplp_list[[i]] <- NULL
  } else {
    eplp_list[[i]] <- content(response, "parsed")
  }
}

# Now you can access player data like this:
eplp_list[[1]]$response[[1]]$player

eplp1
