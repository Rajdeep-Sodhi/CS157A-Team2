CREATE DATABASE IF NOT EXISTS worldcup2026;
USE worldcup2026;
 
CREATE TABLE IF NOT EXISTS Countries (
    country_id   INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    fifa_ranking INT,
    confederation VARCHAR(50)
);
 
CREATE TABLE IF NOT EXISTS Teams (
    team_id      INT AUTO_INCREMENT PRIMARY KEY,
    country_id   INT NOT NULL,
    group_letter CHAR(1),
    coach_name   VARCHAR(100),
    FOREIGN KEY (country_id) REFERENCES Countries(country_id)
);
 
CREATE TABLE IF NOT EXISTS Venues (
    venue_id     INT AUTO_INCREMENT PRIMARY KEY,
    stadium_name VARCHAR(100) NOT NULL,
    city         VARCHAR(100),
    host_country VARCHAR(100),
    capacity     INT
);
 
CREATE TABLE IF NOT EXISTS Matches (
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
 
CREATE TABLE IF NOT EXISTS GroupStandings (
    standing_id INT AUTO_INCREMENT PRIMARY KEY,
    team_id     INT NOT NULL,
    wins        INT DEFAULT 0,
    draws       INT DEFAULT 0,
    losses      INT DEFAULT 0,
    goal_diff   INT DEFAULT 0,
    points      INT DEFAULT 0,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);
 
CREATE TABLE IF NOT EXISTS Users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          ENUM('guest','fan','admin') DEFAULT 'fan'
);
 
-- ===== Previously missing tables (were never in schema.sql) =====
 
CREATE TABLE IF NOT EXISTS Players (
    player_id      INT AUTO_INCREMENT PRIMARY KEY,
    team_id        INT NOT NULL,
    name           VARCHAR(100) NOT NULL,
    position       VARCHAR(50),
    jersey_number  INT,
    date_of_birth  DATE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);
 
CREATE TABLE IF NOT EXISTS PlayerStats (
    stat_id         INT PRIMARY KEY,
    player_id       INT NOT NULL,
    goals           INT DEFAULT 0,
    assists         INT DEFAULT 0,
    minutes_played  INT DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);
 
CREATE TABLE IF NOT EXISTS Referees (
    referee_id  INT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL
);
 
CREATE TABLE IF NOT EXISTS MatchResults (
    result_id       INT PRIMARY KEY,
    match_id        INT NOT NULL,
    team1_score     INT,
    team2_score     INT,
    winner_team_id  INT,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (winner_team_id) REFERENCES Teams(team_id)
);
 
CREATE TABLE IF NOT EXISTS MatchEvents (
    event_id    INT PRIMARY KEY,
    match_id    INT NOT NULL,
    player_id   INT NOT NULL,
    event_type  VARCHAR(50),
    minute      INT,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);
 
CREATE TABLE IF NOT EXISTS Predictions (
    prediction_id           INT PRIMARY KEY,
    user_id                 INT NOT NULL,
    match_id                INT NOT NULL,
    predicted_team1_score   INT,
    predicted_team2_score   INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);
 
CREATE TABLE IF NOT EXISTS Sponsors (
    sponsor_id       INT PRIMARY KEY,
    sponsor_name     VARCHAR(100) NOT NULL,
    contract_amount  DECIMAL(12,2)
);
 
CREATE TABLE IF NOT EXISTS MatchSponsors (
    match_id   INT NOT NULL,
    sponsor_id INT NOT NULL,
    PRIMARY KEY (match_id, sponsor_id),
    FOREIGN KEY (match_id)   REFERENCES Matches(match_id),
    FOREIGN KEY (sponsor_id) REFERENCES Sponsors(sponsor_id)
);