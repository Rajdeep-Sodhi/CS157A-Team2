-- seed_data

USE worldcup2026;

INSERT INTO Users (email, name, password_hash, role) VALUES
('rajdeep.sodhi@sjsu.edu', 'Rajdeep', 'password', 'admin'),
('anthony.moll@sjsu.edu', 'Anthony', 'password', 'admin'),
('thingocduyen.lam@sjsu.edu', 'Thi', 'password', 'admin'),
('mike.wu@sjsu.edu', 'Mike', 'password', 'fan'),
('sarah.kim@sjsu.edu', 'Sarah', 'password', 'fan'),
('david.chen@sjsu.edu', 'David', 'password', 'fan'),
('maria.garcia@sjsu.edu', 'Maria', 'password', 'fan'),
('james.wilson@sjsu.edu', 'James', 'password', 'fan'),
('emily.brown@sjsu.edu', 'Emily', 'password', 'fan'),
('carlos.rodriguez@sjsu.edu', 'Carlos', 'password', 'fan'),
('linda.martinez@sjsu.edu', 'Linda', 'password', 'fan'),
('kevin.lee@sjsu.edu', 'Kevin', 'password', 'fan');


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
('Curacao', 82, 'CONCACAF', NULL, 'E'),
('Ivory Coast', 31, 'CAF', NULL, 'E'),
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
    (country_name, jersey_number, name, date_of_birth, position)
VALUES
-- Argentina
('Argentina', 10, 'Lionel Messi', '1987-06-24', 'Forward'),

-- Portugal
('Portugal', 7, 'Cristiano Ronaldo', '1985-02-05', 'Forward'),
('Portugal', 8, 'Bruno Fernandes', '1994-09-08', 'Midfielder'),

-- France
('France', 10, 'Kylian Mbappe', '1998-12-20', 'Forward'),
('France', 7, 'Ousmane Dembele', '1997-05-15', 'Forward'),

-- Norway
('Norway', 9, 'Erling Haaland', '2000-07-21', 'Forward'),

-- Spain
('Spain', 19, 'Lamine Yamal', '2007-07-13', 'Forward'),
('Spain', 16, 'Rodri', '1996-06-22', 'Midfielder'),
('Spain', 8, 'Pedri', '2002-11-25', 'Midfielder'),

-- Brazil
('Brazil', 7, 'Vinicius Junior', '2000-07-12', 'Forward'),
('Brazil', 11, 'Raphinha', '1996-12-14', 'Forward'),

-- England
('England', 10, 'Jude Bellingham', '2003-06-29', 'Midfielder'),
('England', 9, 'Harry Kane', '1993-07-28', 'Forward'),
('England', 7, 'Bukayo Saka', '2001-09-05', 'Forward'),

-- Egypt
('Egypt', 11, 'Mohamed Salah', '1992-06-15', 'Forward'),

-- United States
('United States', 10, 'Christian Pulisic', '1998-09-18', 'Forward'),

-- South Korea
('South Korea', 7, 'Son Heung-min', '1992-07-08', 'Forward'),

-- Croatia
('Croatia', 10, 'Luka Modric', '1985-09-09', 'Midfielder'),

-- Belgium
('Belgium', 7, 'Kevin De Bruyne', '1991-06-28', 'Midfielder'),
('Belgium', 9, 'Romelu Lukaku', '1993-05-13', 'Forward'),

-- Colombia
('Colombia', 7, 'Luis Diaz', '1997-01-13', 'Forward'),
('Colombia', 10, 'James Rodriguez', '1991-07-12', 'Midfielder'),

-- Uruguay
('Uruguay', 15, 'Federico Valverde', '1998-07-22', 'Midfielder'),

-- Germany
('Germany', 14, 'Jamal Musiala', '2003-02-26', 'Midfielder'),
('Germany', 17, 'Florian Wirtz', '2003-05-03', 'Midfielder'),

-- Morocco
('Morocco', 2, 'Achraf Hakimi', '1998-11-04', 'Defender'),

-- Canada
('Canada', 19, 'Alphonso Davies', '2000-11-02', 'Defender'),
('Canada', 20, 'Jonathan David', '2000-01-14', 'Forward'),

-- Algeria
('Algeria', 7, 'Riyad Mahrez', '1991-02-21', 'Forward'),

-- Mexico
('Mexico', 13, 'Guillermo Ochoa', '1985-07-13', 'Goalkeeper');


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


-- Match 2: South Korea 2-1 Czechia
INSERT INTO Matches (
    team1_country_name,
    team2_country_name,
    venue_id,
    referee_id,
    match_date,
    stage
)
VALUES (
    'South Korea',
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
VALUES (@match_2, 2, 1, 'South Korea');


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


-- Match 12: Mexico vs South Korea
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
    'South Korea',
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


-- RELATIONSHIP TABLES

INSERT INTO PlaysAsTeam1 (match_id, country_name) VALUES
(@match_1, 'Mexico'),
(@match_2, 'South Korea'),
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
(@match_12, 'South Korea'),
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
('South Korea', 1, 0, 0, 3),
('South Africa', 0, 0, 1, 0),
('Czechia', 0, 0, 1, 0),

-- Group B
('Canada', 0, 1, 0, 1),
('Bosnia and Herzegovina', 0, 1, 0, 1),
('Qatar', 0, 0, 0, 0),
('Switzerland', 0, 0, 0, 0),

-- Group C
('Brazil', 0, 1, 0, 1),
('Morocco', 0, 1, 0, 1),
('Haiti', 0, 0, 0, 0),
('Scotland', 0, 0, 0, 0),

-- Group D
('United States', 1, 0, 0, 3),
('Paraguay', 0, 0, 1, 0),
('Australia', 0, 0, 0, 0),
('Türkiye', 0, 0, 0, 0),

-- Group E
('Germany', 1, 0, 0, 3),
('Curacao', 0, 0, 1, 0),
('Ivory Coast', 0, 0, 0, 0),
('Ecuador', 0, 0, 0, 0),

-- Group F
('Netherlands', 0, 0, 0, 0),
('Japan', 0, 0, 0, 0),
('Sweden', 0, 0, 0, 0),
('Tunisia', 0, 0, 0, 0),

-- Group G
('Belgium', 0, 0, 0, 0),
('Egypt', 0, 0, 0, 0),
('Iran', 0, 0, 0, 0),
('New Zealand', 0, 0, 0, 0),

-- Group H
('Spain', 0, 1, 0, 1),
('Cabo Verde', 0, 1, 0, 1),
('Saudi Arabia', 0, 0, 0, 0),
('Uruguay', 0, 0, 0, 0),

-- Group I
('France', 1, 0, 0, 3),
('Senegal', 0, 0, 1, 0),
('Iraq', 0, 0, 0, 0),
('Norway', 0, 0, 0, 0),

-- Group J
('Argentina', 1, 0, 0, 3),
('Algeria', 0, 0, 1, 0),
('Austria', 0, 0, 0, 0),
('Jordan', 0, 0, 0, 0),

-- Group K
('Portugal', 0, 0, 0, 0),
('Congo DR', 0, 0, 0, 0),
('Uzbekistan', 0, 0, 0, 0),
('Colombia', 0, 0, 0, 0),

-- Group L
('England', 1, 0, 0, 3),
('Croatia', 0, 0, 1, 0),
('Ghana', 0, 0, 0, 0),
('Panama', 0, 0, 0, 0);


-- ADDITIONAL SEED DATA 

-- PlayerStats: (country_name, jersey_number) identifies the player directly now.
INSERT INTO PlayerStats (country_name, jersey_number, goals, assists, minutes_played) VALUES
('Argentina', 10, 1, 1, 90),
('France', 10, 2, 0, 90),
('France', 7, 1, 1, 85),
('Spain', 19, 0, 0, 90),
('Brazil', 7, 1, 0, 90),
('England', 10, 1, 1, 90),
('England', 9, 2, 0, 90),
('United States', 10, 1, 1, 90),
('South Korea', 7, 1, 0, 90),
('Croatia', 10, 0, 1, 90),
('Germany', 14, 2, 2, 80),
('Morocco', 2, 0, 1, 90);

INSERT INTO MatchEvents (match_id, country_name, player_jersey_number, event_type, minute) VALUES
(@match_9, 'Argentina', 10, 'Goal', 23),
(@match_8, 'France', 10, 'Goal', 15),
(@match_8, 'France', 10, 'Goal', 67),
(@match_8, 'France', 7, 'Assist', 15),
(@match_10, 'England', 10, 'Goal', 34),
(@match_10, 'England', 9, 'Goal', 12),
(@match_10, 'England', 9, 'Goal', 78),
(@match_4, 'United States', 10, 'Goal', 55),
(@match_2, 'South Korea', 7, 'Goal', 41),
(@match_6, 'Germany', 14, 'Goal', 20),
(@match_6, 'Germany', 14, 'Goal', 60),
(@match_5, 'Morocco', 2, 'Assist', 30);

-- Comments
INSERT INTO Comments (user_id, match_id, content) VALUES
(1, @match_1, 'Great start for Mexico!'),
(2, @match_1, 'Solid defense from South Africa despite the loss.'),
(3, @match_2, 'Son was electric today.'),
(4, @match_3, 'Exciting draw, both teams played well.'),
(5, @match_4, 'Pulisic finally showing up on the big stage.'),
(6, @match_5, 'Brazil looked flat in this one.'),
(7, @match_6, 'Germany absolutely dominant, 7 goals!'),
(8, @match_7, 'Boring 0-0 but tactically interesting.'),
(9, @match_8, 'Mbappe is unstoppable.'),
(10, @match_9, 'Messi magic once again.'),
(11, @match_10, 'England front three is scary good.'),
(1, @match_10, 'Croatia gave it their all.');

SET @comment_1 = (SELECT comment_id FROM Comments WHERE user_id = 1 AND match_id = @match_1 LIMIT 1);
SET @comment_2 = (SELECT comment_id FROM Comments WHERE user_id = 2 AND match_id = @match_1 LIMIT 1);
SET @comment_3 = (SELECT comment_id FROM Comments WHERE user_id = 3 AND match_id = @match_2 LIMIT 1);
SET @comment_4 = (SELECT comment_id FROM Comments WHERE user_id = 4 AND match_id = @match_3 LIMIT 1);
SET @comment_5 = (SELECT comment_id FROM Comments WHERE user_id = 5 AND match_id = @match_4 LIMIT 1);
SET @comment_6 = (SELECT comment_id FROM Comments WHERE user_id = 6 AND match_id = @match_5 LIMIT 1);

-- CommentVotes: (comment_id, user_id) must be unique, so no voter
-- votes on the same comment twice.
INSERT INTO CommentVotes (comment_id, user_id, vote_value) VALUES
(@comment_1, 2, 1),
(@comment_1, 3, 1),
(@comment_1, 4, -1),
(@comment_2, 1, 1),
(@comment_2, 5, 1),
(@comment_3, 6, 1),
(@comment_3, 7, -1),
(@comment_4, 8, 1),
(@comment_5, 9, 1),
(@comment_6, 10, 1),
(@comment_6, 11, 1);

-- Predictions: predictions on the still-unplayed matches (11-15).
INSERT INTO Predictions (user_id, match_id, predicted_team1_score, predicted_team2_score) VALUES
(1, @match_11, 1, 0),
(2, @match_11, 2, 1),
(3, @match_12, 1, 1),
(4, @match_12, 2, 0),
(5, @match_13, 3, 0),
(6, @match_13, 2, 1),
(7, @match_14, 2, 0),
(8, @match_14, 3, 1),
(9, @match_15, 1, 1),
(10, @match_15, 2, 0),
(11, @match_11, 0, 0),
(12, @match_12, 1, 0);

-- Officiates: referee_id refers to the Referees insert order above.
-- Chosen so no referee's own country is one of the two teams playing.
INSERT INTO Officiates (referee_id, match_id) VALUES
(3, @match_1),   -- Japan referees Mexico vs South Africa
(4, @match_2),   -- Somalia referees South Korea vs Czechia
(9, @match_3),   -- Costa Rica referees Canada vs Bosnia and Herzegovina
(12, @match_4),  -- Norway referees United States vs Paraguay
(22, @match_5),  -- New Zealand referees Brazil vs Morocco
(23, @match_6),  -- Romania referees Germany vs Curacao
(25, @match_7),  -- China referees Spain vs Cabo Verde
(26, @match_8),  -- Jordan referees France vs Senegal
(27, @match_9),  -- Netherlands referees Argentina vs Algeria
(28, @match_10); -- Poland referees England vs Croatia