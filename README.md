# gitball

## Overview

gitball is an R-based engineering pipeline and data platform for a fantasy football game with a unique twist: players interact with the game by performing git-like actions. The project leverages R for data ingestion, transformation, and database population, and uses real football data to power the fantasy experience.

## Key Features
- **Fantasy Football with Git Actions:** Players' in-game actions (such as transfers, trades, or strategy changes) are modeled as git operations (commits, branches, merges, etc.), creating a novel and collaborative gameplay experience.
- **Automated Data Pipeline:** R scripts fetch, normalize, and populate football data (leagues, teams, players, fixtures, events, stats) from the API-Football service into an Azure SQL database.
- **Modern Data Engineering:** Utilizes best practices in R for reproducibility, modularity, and robust data handling.
- **Cloud-Ready:** Designed for integration with cloud databases and scalable workflows.

## Components
- `setup_database.R`: Creates and initializes the normalized database schema.
- `git_init.R`: Populates all tables with up-to-date football data from API-Football.
- `git_load.R`: Additional data loading and processing utilities.

## Getting Started
1. Clone the repository.
2. Set up your `.Renv` file with the required API keys and database credentials.
3. Run `setup_database.R` to initialize the schema.
4. Run `git_init.R` to populate the database.

## Inspiration
This project is inspired by the intersection of software engineering (git workflows) and the world of fantasy football, aiming to create a collaborative, data-driven, and fun gaming experience for engineers and football fans alike. 