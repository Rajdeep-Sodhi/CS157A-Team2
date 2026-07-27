-- seed_data

USE worldcup2026;

INSERT INTO Users (email, name, password_hash, role) VALUES
('rajdeep.sodhi@sjsu.edu', 'Rajdeep', 'password', 'admin'),
('anthony.moll@sjsu.edu', 'Anthony', 'password', 'admin'),
('thingocduyen.lam@sjsu.edu', 'Thi', 'password', 'admin'),
('mike.wu@sjsu.edu', 'Mike', 'password', 'fan');


INSERT INTO Countries (country_name, fifa_ranking, confederation, coach_name, group_letter) VALUES
('Mexico', 10, 'CONCACAF', NULL, 'A'),
('South Africa', 54, 'CAF', NULL, 'A'),
('South Korea', 32, 'AFC', NULL, 'A'),
('Czechia', 48, 'UEFA', NULL, 'A'),
('Canada', 30, 'CONCACAF', NULL, 'B'),
('Bosnia and Herzegovina', 61, 'UEFA', NULL, 'B'),
('Qatar', 59, 'AFC', NULL, 'B'),
('Switzerland', 14, 'UEFA', NULL, 'B'),
('Brazil', 5, 'CONMEBOL', NULL, 'C'),
('Morocco', 6, 'CAF', NULL, 'C'),
('Haiti', 88, 'CONCACAF', NULL, 'C'),
('Scotland', 42, 'UEFA', NULL, 'C'),
('United States', 16, 'CONCACAF', NULL, 'D'),
('Paraguay', 34, 'CONMEBOL', NULL, 'D'),
('Australia', 28, 'AFC', NULL, 'D'),
('Türkiye', 27, 'UEFA', NULL, 'D'),
('Germany', 12, 'UEFA', NULL, 'E'),
('Curaçao', 82, 'CONCACAF', NULL, 'E'),
('Côte d''Ivoire', 31, 'CAF', NULL, 'E'),
('Ecuador', 25, 'CONMEBOL', NULL, 'E'),
('Netherlands', 9, 'UEFA', NULL, 'F'),
('Japan', 17, 'AFC', NULL, 'F'),
('Sweden', 37, 'UEFA', NULL, 'F'),
('Tunisia', 57, 'CAF', NULL, 'F'),
('Belgium', 8, 'UEFA', NULL, 'G'),
('Egypt', 24, 'CAF', NULL, 'G'),
('Iran', 22, 'AFC', NULL, 'G'),
('New Zealand', 86, 'OFC', NULL, 'G'),
('Spain', 1, 'UEFA', NULL, 'H'),
('Cabo Verde', 64, 'CAF', NULL, 'H'),
('Saudi Arabia', 58, 'AFC', NULL, 'H'),
('Uruguay', 20, 'CONMEBOL', NULL, 'H'),
('France', 3, 'UEFA', NULL, 'I'),
('Senegal', 18, 'CAF', NULL, 'I'),
('Iraq', 63, 'AFC', NULL, 'I'),
('Norway', 19, 'UEFA', NULL, 'I'),
('Argentina', 2, 'CONMEBOL', NULL, 'J'),
('Algeria', 29, 'CAF', NULL, 'J'),
('Austria', 23, 'UEFA', NULL, 'J'),
('Jordan', 73, 'AFC', NULL, 'J'),
('Portugal', 7, 'UEFA', NULL, 'K'),
('Congo DR', 41, 'CAF', NULL, 'K'),
('Uzbekistan', 60, 'AFC', NULL, 'K'),
('Colombia', 11, 'CONMEBOL', NULL, 'K'),
('England', 4, 'UEFA', NULL, 'L'),
('Croatia', 13, 'UEFA', NULL, 'L'),
('Ghana', 65, 'CAF', NULL, 'L'),
('Panama', 44, 'CONCACAF', NULL, 'L');

INSERT INTO Referees (country_name, name) VALUES
('Qatar', 'Abdulrahman Al Jassim'),
('Saudi Arabia', 'Khalid Al Turais'),
('Japan', 'Yusuke Araki'),
('Somalia', 'Omar Abdulkadir Artan'),
('Gabon', 'Pierre Atcho'),
('El Salvador', 'Ivan Barton'),
('Mauritania', 'Dahane Beida'),
('Paraguay', 'Juan Gabriel Benitez'),
('Costa Rica', 'Juan Calderon'),
('Brazil', 'Raphael Claus'),
('United States', 'Ismail Elfath'),
('Norway', 'Espen Eskas'),
('Australia', 'Alireza Faghani'),
('Argentina', 'Yael Falcon Perez'),
('Canada', 'Drew Fischer'),
('Chile', 'Cristian Garay'),
('Mexico', 'Katia Garcia'),
('Algeria', 'Mustapha Ghorbal'),
('Spain', 'Alejandro Hernandez'),
('Argentina', 'Dario Herrera'),
('Morocco', 'Jalal Jayed'),
('New Zealand', 'Campbell-Kirk Kawana-Waugh'),
('Romania', 'Istvan Kovacs'),
('France', 'Francois Letexier'),
('China', 'Ning Ma'),
('Jordan', 'Adham Makhadmeh'),
('Netherlands', 'Danny Makkelie'),
('Poland', 'Szymon Marciniak'),
('Italy', 'Maurizio Mariani'),
('Honduras', 'Hector Said Martinez'),
('Egypt', 'Amin Mohamed'),
('Jamaica', 'Oshane Nation'),
('Sweden', 'Glenn Nyberg'),
('England', 'Michael Oliver'),
('United Arab Emirates', 'Omar Al Ali'),
('Peru', 'Kevin Ortega'),
('United States', 'Tori Penso'),
('Portugal', 'Joao Pinheiro'),
('Brazil', 'Ramon Abatti'),
('Mexico', 'Cesar Ramos'),
('Colombia', 'Andres Rojas'),
('Switzerland', 'Sandro Schaerer'),
('Uzbekistan', 'Ilgiz Tantashev'),
('England', 'Anthony Taylor'),
('Uruguay', 'Gustavo Tejera'),
('Argentina', 'Facundo Tello'),
('South Africa', 'Abongile Tom'),
('France', 'Clement Turpin'),
('Venezuela', 'Jesus Valenzuela'),
('Slovenia', 'Slavko Vincic'),
('Brazil', 'Wilton Sampaio'),
('Germany', 'Felix Zwayer');

INSERT INTO Venues (stadium_name, city, host_country, capacity) VALUES
-- Canada
('Toronto Stadium', 'Toronto', 'Canada', 43036),
('BC Place Vancouver', 'Vancouver', 'Canada', 52497),

-- Mexico
('Mexico City Stadium', 'Mexico City', 'Mexico', 80824),
('Guadalajara Stadium', 'Guadalajara', 'Mexico', 45664),
('Monterrey Stadium', 'Monterrey', 'Mexico', NULL),

-- United States
('Atlanta Stadium', 'Atlanta', 'United States', NULL),
('Boston Stadium', 'Foxborough', 'United States', NULL),
('Dallas Stadium', 'Arlington', 'United States', NULL),
('Houston Stadium', 'Houston', 'United States', NULL),
('Kansas City Stadium', 'Kansas City', 'United States', NULL),
('Los Angeles Stadium', 'Inglewood', 'United States', NULL),
('Miami Stadium', 'Miami Gardens', 'United States', NULL),
('New York New Jersey Stadium', 'East Rutherford', 'United States', NULL),
('Philadelphia Stadium', 'Philadelphia', 'United States', NULL),
('San Francisco Bay Area Stadium', 'Santa Clara', 'United States', NULL),
('Seattle Stadium', 'Seattle', 'United States', NULL);

INSERT INTO Players
    (country_name, name, date_of_birth, position, jersey_number)
VALUES
-- Argentina
('Argentina', 'Lionel Messi', '1987-06-24', 'Forward', NULL),

-- Portugal
('Portugal', 'Cristiano Ronaldo', '1985-02-05', 'Forward', NULL),
('Portugal', 'Bruno Fernandes', '1994-09-08', 'Midfielder', NULL),

-- France
('France', 'Kylian Mbappe', '1998-12-20', 'Forward', NULL),
('France', 'Ousmane Dembele', '1997-05-15', 'Forward', NULL),

-- Norway
('Norway', 'Erling Haaland', '2000-07-21', 'Forward', NULL),

-- Spain
('Spain', 'Lamine Yamal', '2007-07-13', 'Forward', NULL),
('Spain', 'Rodri', '1996-06-22', 'Midfielder', NULL),
('Spain', 'Pedri', '2002-11-25', 'Midfielder', NULL),

-- Brazil
('Brazil', 'Vinicius Junior', '2000-07-12', 'Forward', NULL),
('Brazil', 'Raphinha', '1996-12-14', 'Forward', NULL),

-- England
('England', 'Jude Bellingham', '2003-06-29', 'Midfielder', NULL),
('England', 'Harry Kane', '1993-07-28', 'Forward', NULL),
('England', 'Bukayo Saka', '2001-09-05', 'Forward', NULL),

-- Egypt
('Egypt', 'Mohamed Salah', '1992-06-15', 'Forward', NULL),

-- United States
('United States', 'Christian Pulisic', '1998-09-18', 'Forward', NULL),

-- South Korea
('South Korea', 'Son Heung-min', '1992-07-08', 'Forward', NULL),

-- Croatia
('Croatia', 'Luka Modric', '1985-09-09', 'Midfielder', NULL),

-- Belgium
('Belgium', 'Kevin De Bruyne', '1991-06-28', 'Midfielder', NULL),
('Belgium', 'Romelu Lukaku', '1993-05-13', 'Forward', NULL),

-- Colombia
('Colombia', 'Luis Diaz', '1997-01-13', 'Forward', NULL),
('Colombia', 'James Rodriguez', '1991-07-12', 'Midfielder', NULL),

-- Uruguay
('Uruguay', 'Federico Valverde', '1998-07-22', 'Midfielder', NULL),

-- Germany
('Germany', 'Jamal Musiala', '2003-02-26', 'Midfielder', NULL),
('Germany', 'Florian Wirtz', '2003-05-03', 'Midfielder', NULL),

-- Morocco
('Morocco', 'Achraf Hakimi', '1998-11-04', 'Defender', NULL),

-- Canada
('Canada', 'Alphonso Davies', '2000-11-02', 'Defender', NULL),
('Canada', 'Jonathan David', '2000-01-14', 'Forward', NULL),

-- Algeria
('Algeria', 'Riyad Mahrez', '1991-02-21', 'Forward', NULL),

-- Mexico
('Mexico', 'Guillermo Ochoa', '1985-07-13', 'Goalkeeper', NULL);


-- Match 1: Mexico 2-0 South Africa
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Mexico',
    'South Africa',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Mexico City Stadium'
     LIMIT 1),
    NULL,
    '2026-06-11 12:00:00',
    'Group Stage'
);

SET @match_1 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_1, 2, 0, 'Mexico');


-- Match 2: Korea Republic 2-1 Czechia
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Korea Republic',
    'Czechia',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Guadalajara Stadium'
     LIMIT 1),
    NULL,
    '2026-06-12 12:00:00',
    'Group Stage'
);

SET @match_2 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_2, 2, 1, 'Korea Republic');


-- Match 3: Canada 1-1 Bosnia and Herzegovina
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Canada',
    'Bosnia and Herzegovina',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Toronto Stadium'
     LIMIT 1),
    NULL,
    '2026-06-12 12:00:00',
    'Group Stage'
);

SET @match_3 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_3, 1, 1, NULL);


-- Match 4: United States 4-1 Paraguay
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'United States',
    'Paraguay',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Los Angeles Stadium'
     LIMIT 1),
    NULL,
    '2026-06-13 12:00:00',
    'Group Stage'
);

SET @match_4 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_4, 4, 1, 'United States');


-- Match 5: Brazil 1-1 Morocco
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Brazil',
    'Morocco',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'New York New Jersey Stadium'
     LIMIT 1),
    NULL,
    '2026-06-13 12:00:00',
    'Group Stage'
);

SET @match_5 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_5, 1, 1, NULL);


-- Match 6: Germany 7-1 Curacao
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Germany',
    'Curacao',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Houston Stadium'
     LIMIT 1),
    NULL,
    '2026-06-14 12:00:00',
    'Group Stage'
);

SET @match_6 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_6, 7, 1, 'Germany');


-- Match 7: Spain 0-0 Cabo Verde
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Spain',
    'Cabo Verde',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Atlanta Stadium'
     LIMIT 1),
    NULL,
    '2026-06-15 12:00:00',
    'Group Stage'
);

SET @match_7 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_7, 0, 0, NULL);


-- Match 8: France 3-1 Senegal
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'France',
    'Senegal',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'New York New Jersey Stadium'
     LIMIT 1),
    NULL,
    '2026-06-16 12:00:00',
    'Group Stage'
);

SET @match_8 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_8, 3, 1, 'France');


-- Match 9: Argentina 3-0 Algeria
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Argentina',
    'Algeria',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Kansas City Stadium'
     LIMIT 1),
    NULL,
    '2026-06-17 12:00:00',
    'Group Stage'
);

SET @match_9 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_9, 3, 0, 'Argentina');


-- Match 10: England 4-2 Croatia
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'England',
    'Croatia',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Dallas Stadium'
     LIMIT 1),
    NULL,
    '2026-06-17 12:00:00',
    'Group Stage'
);

SET @match_10 = LAST_INSERT_ID();

INSERT INTO MatchResults (
    match_id,
    team1_score,
    team2_score,
    winner_country_name
)
VALUES (@match_10, 4, 2, 'England');

-- Match 11: Canada vs Qatar
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Canada',
    'Qatar',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'BC Place Vancouver'
     LIMIT 1),
    NULL,
    '2026-06-18 12:00:00',
    'Group Stage'
);

SET @match_11 = LAST_INSERT_ID();


-- Match 12: Mexico vs Korea Republic
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Mexico',
    'Korea Republic',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Guadalajara Stadium'
     LIMIT 1),
    NULL,
    '2026-06-19 12:00:00',
    'Group Stage'
);

SET @match_12 = LAST_INSERT_ID();


-- Match 13: United States vs Australia
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'United States',
    'Australia',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Seattle Stadium'
     LIMIT 1),
    NULL,
    '2026-06-19 12:00:00',
    'Group Stage'
);

SET @match_13 = LAST_INSERT_ID();


-- Match 14: Brazil vs Haiti
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Brazil',
    'Haiti',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Philadelphia Stadium'
     LIMIT 1),
    NULL,
    '2026-06-20 12:00:00',
    'Group Stage'
);

SET @match_14 = LAST_INSERT_ID();


-- Match 15: Spain vs Saudi Arabia
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'Spain',
    'Saudi Arabia',
    (SELECT venue_id
     FROM Venues
     WHERE stadium_name = 'Atlanta Stadium'
     LIMIT 1),
    NULL,
    '2026-06-21 12:00:00',
    'Group Stage'
);

SET @match_15 = LAST_INSERT_ID();


-- =========================================================
-- RELATIONSHIP TABLES
-- =========================================================

INSERT INTO PlaysAsTeam1 (match_id, country_name) VALUES
(@match_1, 'Mexico'),
(@match_2, 'Korea Republic'),
(@match_3, 'Canada'),
(@match_4, 'United States'),
(@match_5, 'Brazil'),
(@match_6, 'Germany'),
(@match_7, 'Spain'),
(@match_8, 'France'),
(@match_9, 'Argentina'),
(@match_10, 'England'),
(@match_11, 'Canada'),
(@match_12, 'Mexico'),
(@match_13, 'United States'),
(@match_14, 'Brazil'),
(@match_15, 'Spain');


INSERT INTO PlaysAsTeam2 (match_id, country_name) VALUES
(@match_1, 'South Africa'),
(@match_2, 'Czechia'),
(@match_3, 'Bosnia and Herzegovina'),
(@match_4, 'Paraguay'),
(@match_5, 'Morocco'),
(@match_6, 'Curacao'),
(@match_7, 'Cabo Verde'),
(@match_8, 'Senegal'),
(@match_9, 'Algeria'),
(@match_10, 'Croatia'),
(@match_11, 'Qatar'),
(@match_12, 'Korea Republic'),
(@match_13, 'Australia'),
(@match_14, 'Haiti'),
(@match_15, 'Saudi Arabia');


INSERT INTO HostedAt (venue_id, match_id)
SELECT venue_id, match_id
FROM Matches
WHERE match_id IN (
    @match_1,
    @match_2,
    @match_3,
    @match_4,
    @match_5,
    @match_6,
    @match_7,
    @match_8,
    @match_9,
    @match_10,
    @match_11,
    @match_12,
    @match_13,
    @match_14,
    @match_15
);

INSERT INTO GroupStandings
    (country_name, wins, draws, losses, points)
VALUES
-- Group A
('Mexico', 1, 0, 0, 3),
('Korea Republic', 1, 0, 0, 3),
('Canada', 0, 1, 0, 1),
('Bosnia and Herzegovina', 0, 1, 0, 1),

-- Group B
('United States', 1, 0, 0, 3),
('Brazil', 0, 1, 0, 1),
('Morocco', 0, 1, 0, 1),
('Paraguay', 0, 0, 1, 0),

-- Group C
('Germany', 1, 0, 0, 3),
('Spain', 0, 1, 0, 1),
('Cabo Verde', 0, 1, 0, 1),
('Curacao', 0, 0, 1, 0),

-- Group D
('France', 1, 0, 0, 3),
('Argentina', 1, 0, 0, 3),
('Senegal', 0, 0, 1, 0),
('Algeria', 0, 0, 1, 0),

-- Group E
('England', 1, 0, 0, 3),
('Croatia', 0, 0, 1, 0),
('Qatar', 0, 0, 0, 0),
('Australia', 0, 0, 0, 0),

-- Group F
('Portugal', 0, 0, 0, 0),
('Belgium', 0, 0, 0, 0),
('Colombia', 0, 0, 0, 0),
('Haiti', 0, 0, 0, 0),

-- Group G
('Norway', 0, 0, 0, 0),
('Egypt', 0, 0, 0, 0),
('Saudi Arabia', 0, 0, 0, 0),
('Japan', 0, 0, 0, 0),

-- Group H
('Uruguay', 0, 0, 0, 0),
('Switzerland', 0, 0, 0, 0),
('Austria', 0, 0, 0, 0),
('Ghana', 0, 0, 0, 0),

-- Group I
('Netherlands', 0, 0, 0, 0),
('Ivory Coast', 0, 0, 0, 0),
('South Africa', 0, 0, 1, 0),
('Czechia', 0, 0, 1, 0),

-- Group J
('Italy', 0, 0, 0, 0),
('Denmark', 0, 0, 0, 0),
('Ecuador', 0, 0, 0, 0),
('Tunisia', 0, 0, 0, 0),

-- Group K
('Poland', 0, 0, 0, 0),
('Sweden', 0, 0, 0, 0),
('Serbia', 0, 0, 0, 0),
('Costa Rica', 0, 0, 0, 0),

-- Group L
('Chile', 0, 0, 0, 0),
('Nigeria', 0, 0, 0, 0),
('Cameroon', 0, 0, 0, 0),
('New Zealand', 0, 0, 0, 0);
