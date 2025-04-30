library(plumber)
library(DBI)
library(odbc)

# Load environment variables
readRenviron(".Renv")
db_host <- Sys.getenv("DB_HOST")
db_port <- as.integer(Sys.getenv("DB_PORT"))
db_name <- Sys.getenv("DB_NAME")
client_id <- Sys.getenv("AZURE_CLIENT_ID")
client_secret <- Sys.getenv("AZURE_CLIENT_SECRET")

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

#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, DELETE")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }
  plumber::forward()
}

#* @apiTitle Gitball API

#* Get all teams
#* @get /teams
function() {
  conn <- dbConnect(odbc::odbc(), .connection_string = conn_string, timeout = 10)
  on.exit(dbDisconnect(conn))
  dbGetQuery(conn, "SELECT team_id, name FROM teams ORDER BY name")
}

#* Get player stats (optionally filter by team)
#* @param team_id:int
#* @get /player_stats
function(team_id = NULL) {
  conn <- dbConnect(odbc::odbc(), .connection_string = conn_string, timeout = 10)
  on.exit(dbDisconnect(conn))
  query <- "
    SELECT 
      p.name,
      t.name as team_name,
      COUNT(DISTINCT pms.fixture_id) as games_played,
      AVG(pms.game_rating) as avg_rating,
      SUM(pms.yellow_cards) as yellow_cards,
      SUM(pms.red_cards) as red_cards,
      SUM(pms.penalty_committed) as penalties_committed,
      SUM(pms.penalty_missed) as penalties_missed
    FROM players p
    JOIN teams t ON p.team_id = t.team_id
    LEFT JOIN player_match_stats pms ON p.player_id = pms.player_id 
      AND p.team_id = pms.team_id 
      AND p.season = pms.season
    WHERE p.season = 2024"
  if (!is.null(team_id)) {
    query <- paste0(query, " AND p.team_id = ", as.integer(team_id))
  }
  query <- paste0(query, " GROUP BY p.name, t.name")
  dbGetQuery(conn, query)
}
