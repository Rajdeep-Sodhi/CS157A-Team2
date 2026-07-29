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
    PRIMARY KEY (referee_id)
);

CREATE TABLE Venues (
    venue_id INT AUTO_INCREMENT,
    stadium_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    host_country VARCHAR(100),
    capacity INT,
    PRIMARY KEY (venue_id),
    FOREIGN KEY (host_country) REFERENCES Countries(country_name)
);

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
    content VARCHAR(250) NOT NULL,
    upvote_count INT DEFAULT 0,
    is_flagged BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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

-- ============================================================
-- Migration for Functional Requirements 1-4
-- (Users/roles, Team & Player management, Match management,
--  Stadium/Venue management)
-- Safe to run once against an already-created worldcup2026 DB.
-- Does NOT touch any existing rows/seed data.
-- ============================================================

-- Players.country_name must be nullable so that deleting a team
-- ("Country") can leave its players behind, unassigned
-- ("Not on a Team"), instead of destroying their records.
ALTER TABLE Players MODIFY country_name VARCHAR(100) NULL;

-- A venue can't host two matches at the same date/time.
-- (Enforced in application code too, but backed here at the DB level.)
ALTER TABLE Matches ADD CONSTRAINT uq_venue_datetime UNIQUE (venue_id, match_date);

-- The registration form collects date of birth and country
-- (per the functional requirements), but Users never had
-- columns for them. Both are optional/nullable so this doesn't
-- affect any existing seeded rows.
ALTER TABLE Users ADD COLUMN date_of_birth DATE NULL;
ALTER TABLE Users ADD COLUMN country VARCHAR(100) NULL;
