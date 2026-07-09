
-- ================================================
-- FIFA World Cup 2026 - CS157A Team 2
-- schema.sql: Run this FIRST in MySQL Workbench
-- ================================================
CREATE DATABASE IF NOT EXISTS worldcup2026;
USE worldcup2026;

CREATE TABLE Countries (
    country_id   INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    fifa_ranking INT,
    confederation VARCHAR(50)
);

CREATE TABLE Teams (
    team_id      INT AUTO_INCREMENT PRIMARY KEY,
    country_id   INT NOT NULL,
    group_letter CHAR(1),
    coach_name   VARCHAR(100),
    FOREIGN KEY (country_id) REFERENCES Countries(country_id)
);

CREATE TABLE Venues (
    venue_id     INT AUTO_INCREMENT PRIMARY KEY,
    stadium_name VARCHAR(100) NOT NULL,
    city         VARCHAR(100),
    host_country VARCHAR(100),
    capacity     INT
);

CREATE TABLE Matches (
    match_id    INT AUTO_INCREMENT PRIMARY KEY,
    team1_id    INT NOT NULL,
    team2_id    INT NOT NULL,
    venue_id    INT NOT NULL,
    match_date  DATETIME,
    stage       VARCHAR(50),
    team1_score INT DEFAULT NULL,
    team2_score INT DEFAULT NULL,
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id),
    FOREIGN KEY (venue_id) REFERENCES Venues(venue_id)
);

CREATE TABLE GroupStandings (
    standing_id INT AUTO_INCREMENT PRIMARY KEY,
    team_id     INT NOT NULL,
    wins        INT DEFAULT 0,
    draws       INT DEFAULT 0,
    losses      INT DEFAULT 0,
    goal_diff   INT DEFAULT 0,
    points      INT DEFAULT 0,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

CREATE TABLE Users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          ENUM('guest','fan','admin') DEFAULT 'fan'
);

CREATE TABLE `Players` (
  `player_id` int NOT NULL AUTO_INCREMENT,
  `team_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `position` varchar(50) DEFAULT NULL,
  `jersey_number` int DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  PRIMARY KEY (`player_id`),
  KEY `players_teams_fk_idx` (`team_id`),
  CONSTRAINT `players_teams_fk` FOREIGN KEY (`team_id`) REFERENCES `Teams` (`team_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `PlayerStats` (
  `stat_id` int NOT NULL,
  `player_id` int NOT NULL,
  `goals` int DEFAULT NULL,
  `assists` int DEFAULT NULL,
  `minutes_played` int DEFAULT NULL,
  PRIMARY KEY (`stat_id`),
  KEY `playerstats_players_fk_idx` (`player_id`),
  CONSTRAINT `playerstats_players_fk` FOREIGN KEY (`player_id`) REFERENCES `Players` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Referees` (
  `referee_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`referee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `MatchResults` (
  `result_id` int NOT NULL,
  `match_id` int NOT NULL,
  `team1_score` int DEFAULT NULL,
  `team2_score` int DEFAULT NULL,
  `winner_team_id` int DEFAULT NULL,
  PRIMARY KEY (`result_id`),
  KEY `matchresults_matches_fk_idx` (`match_id`),
  KEY `matchresults_teams_fk_idx` (`winner_team_id`),
  CONSTRAINT `matchresults_matches_fk` FOREIGN KEY (`match_id`) REFERENCES `Matches` (`match_id`),
  CONSTRAINT `matchresults_teams_fk` FOREIGN KEY (`winner_team_id`) REFERENCES `Teams` (`team_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

