<<<<<<< Updated upstream
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
=======
CREATE DATABASE worldcup2026;
USE worldcup2026;

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id),
    UNIQUE (email)
);

CREATE TABLE Countries (
    country_name VARCHAR(100),
    fifa_ranking INT,
    confederation VARCHAR(50),
    coach_name VARCHAR(100),
>>>>>>> Stashed changes
    group_letter CHAR(1),
    PRIMARY KEY (country_name)
);

CREATE TABLE Players (
    player_id INT AUTO_INCREMENT,
    country_name VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    position VARCHAR(50),
    jersey_number INT,
    PRIMARY KEY (player_id),
    FOREIGN KEY (country_name) REFERENCES Countries(country_name)
);

CREATE TABLE PlayerStats (
    stat_id INT AUTO_INCREMENT,
    player_id INT NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    goals INT,
    assists INT,
    minutes_played INT,
    PRIMARY KEY (stat_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id),
    FOREIGN KEY (country_name) REFERENCES Countries(country_name)
);

CREATE TABLE Referees (
    referee_id INT AUTO_INCREMENT,
    country_name VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (referee_id),
    FOREIGN KEY (country_name) REFERENCES Countries(country_name)
);
<<<<<<< Updated upstream
 
CREATE TABLE IF NOT EXISTS Venues (
    venue_id     INT AUTO_INCREMENT PRIMARY KEY,
=======

CREATE TABLE Venues (
    venue_id INT AUTO_INCREMENT,
>>>>>>> Stashed changes
    stadium_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    host_country VARCHAR(100),
    capacity INT,
    PRIMARY KEY (venue_id),
    FOREIGN KEY (host_country) REFERENCES Countries(country_name)
);
<<<<<<< Updated upstream
 
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
=======

CREATE TABLE Matches (
    match_id INT AUTO_INCREMENT,
    team1_country_name VARCHAR(100) NOT NULL,
    team2_country_name VARCHAR(100) NOT NULL,
    venue_id INT NOT NULL,
    referee_id INT,
    match_date DATETIME,
    stage VARCHAR(50),
    PRIMARY KEY (match_id),
    FOREIGN KEY (team1_country_name) REFERENCES Countries(country_name),
    FOREIGN KEY (team2_country_name) REFERENCES Countries(country_name),
    FOREIGN KEY (venue_id) REFERENCES Venues(venue_id),
    FOREIGN KEY (referee_id) REFERENCES Referees(referee_id)
);

CREATE TABLE MatchResults (
    result_id INT AUTO_INCREMENT,
    match_id INT NOT NULL,
    team1_score INT,
    team2_score INT,
    winner_country_name VARCHAR(100),
    PRIMARY KEY (result_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (winner_country_name) REFERENCES Countries(country_name)
);

CREATE TABLE MatchEvents (
    event_id INT AUTO_INCREMENT,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    minute INT,
    PRIMARY KEY (event_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id),
    FOREIGN KEY (country_name) REFERENCES Countries(country_name)
);

CREATE TABLE GroupStandings (
    standing_id INT AUTO_INCREMENT,
    country_name VARCHAR(100) NOT NULL,
    wins INT,
    draws INT,
    losses INT,
    points INT,
    PRIMARY KEY (standing_id),
    FOREIGN KEY (country_name) REFERENCES Countries(country_name)
);

CREATE TABLE Sponsors (
    sponsor_id INT AUTO_INCREMENT,
    sponsor_name VARCHAR(100) NOT NULL,
    contract_amount DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (sponsor_id),
    UNIQUE (sponsor_name)
);

CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    match_id INT NOT NULL,
    content TEXT NOT NULL,
    upvote_count INT,
    is_flagged BOOLEAN,
    created_at TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);

CREATE TABLE Predictions (
    prediction_id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    match_id INT NOT NULL,
    predicted_team1_score INT,
    predicted_team2_score INT,
    PRIMARY KEY (prediction_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);

CREATE TABLE PlaysAsTeam1 (
    match_id INT NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (match_id, country_name),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (country_name) REFERENCES Countries(country_name)
);

CREATE TABLE PlaysAsTeam2 (
    match_id INT NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (match_id, country_name),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (country_name) REFERENCES Countries(country_name)
);

CREATE TABLE HostedAt (
    venue_id INT NOT NULL,
    match_id INT NOT NULL,
    PRIMARY KEY (venue_id, match_id),
    FOREIGN KEY (venue_id) REFERENCES Venues(venue_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);

CREATE TABLE SponsoredBy (
    match_id INT NOT NULL,
    sponsor_id INT NOT NULL,
    PRIMARY KEY (match_id, sponsor_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (sponsor_id) REFERENCES Sponsors(sponsor_id)
);

CREATE TABLE Officiates (
    referee_id INT NOT NULL,
    match_id INT NOT NULL,
    PRIMARY KEY (referee_id, match_id),
    FOREIGN KEY (referee_id) REFERENCES Referees(referee_id),
    FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);

CREATE TABLE Nationality (
    country_name VARCHAR(100) NOT NULL,
    referee_id INT NOT NULL,
    PRIMARY KEY (country_name, referee_id),
    FOREIGN KEY (country_name) REFERENCES Countries(country_name),
    FOREIGN KEY (referee_id) REFERENCES Referees(referee_id)
);
>>>>>>> Stashed changes
