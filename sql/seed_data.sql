-- seed_data

USE worldcup2026;

INSERT INTO Countries (country_name, fifa_ranking, confederation) VALUES
('USA',       11, 'CONCACAF'),
('Mexico',    15, 'CONCACAF'),
('Brazil',     5, 'CONMEBOL'),
('Argentina',  1, 'CONMEBOL'),
('France',     2, 'UEFA'),
('Germany',   12, 'UEFA'),
('England',    4, 'UEFA'),
('Spain',      7, 'UEFA');

INSERT INTO Teams (country_id, group_letter, coach_name) VALUES
(1, 'A', 'Mauricio Pochettino'),
(2, 'A', 'Javier Aguirre'),
(3, 'B', 'Dorival Junior'),
(4, 'B', 'Lionel Scaloni'),
(5, 'C', 'Didier Deschamps'),
(6, 'C', 'Julian Nagelsmann'),
(7, 'D', 'Gareth Southgate'),
(8, 'D', 'Luis de la Fuente');

INSERT INTO Venues (stadium_name, city, host_country, capacity) VALUES
('MetLife Stadium',  'New York',     'USA',    82500),
('SoFi Stadium',     'Los Angeles',  'USA',    70240),
('Estadio Azteca',   'Mexico City',  'Mexico', 87523),
('BC Place',         'Vancouver',    'Canada', 54500);

INSERT INTO Matches (team1_id, team2_id, venue_id, match_date, stage, team1_score, team2_score) VALUES
(1, 2, 1, '2026-06-11 18:00:00', 'Group A', 2, 0),
(3, 4, 2, '2026-06-12 18:00:00', 'Group B', 1, 3),
(5, 6, 3, '2026-06-13 18:00:00', 'Group C', NULL, NULL),
(7, 8, 4, '2026-06-14 18:00:00', 'Group D', NULL, NULL),
(1, 3, 1, '2026-06-18 18:00:00', 'Group A', NULL, NULL),
(2, 4, 2, '2026-06-19 18:00:00', 'Group B', NULL, NULL);

INSERT INTO GroupStandings (team_id, wins, draws, losses, goal_diff, points) VALUES
(1, 1, 0, 0,  2, 3),
(2, 0, 0, 1, -2, 0),
(3, 0, 0, 1, -2, 0),
(4, 1, 0, 0,  2, 3),
(5, 0, 0, 0,  0, 0),
(6, 0, 0, 0,  0, 0),
(7, 0, 0, 0,  0, 0),
(8, 0, 0, 0,  0, 0);

INSERT INTO Users (name, email, password_hash, role) VALUES
('Admin',    'admin@worldcup.com', 'changeme', 'admin'),
('Test Fan', 'fan@worldcup.com',   'changeme', 'fan');

INSERT INTO Players (team_id, name, position, jersey_number, date_of_birth) VALUES
(1, 'Christian Pulisic', 'Forward', 10, '1998-09-18'),
(1, 'Weston McKennie', 'Midfielder', 8, '1998-08-28'),
(1, 'Matt Turner', 'Goalkeeper', 1, '1994-06-24'),
(2, 'Santiago Gimenez', 'Forward', 11, '2001-04-18'),
(2, 'Edson Alvarez', 'Midfielder', 4, '1997-10-24'),
(2, 'Luis Malagon', 'Goalkeeper', 1, '1997-03-02'),
(3, 'Vinicius Junior', 'Forward', 7, '2000-07-12'),
(3, 'Rodrygo', 'Forward', 10, '2001-01-09'),
(3, 'Alisson Becker', 'Goalkeeper', 1, '1992-10-02'),
(4, 'Lionel Messi', 'Forward', 10, '1987-06-24'),
(4, 'Julian Alvarez', 'Forward', 9, '2000-01-31'),
(4, 'Emiliano Martinez', 'Goalkeeper', 23, '1992-09-02'),
(5, 'Kylian Mbappe', 'Forward', 10, '1998-12-20'),
(5, 'Aurelien Tchouameni', 'Midfielder', 8, '2000-01-27'),
(5, 'Mike Maignan', 'Goalkeeper', 16, '1995-07-03'),
(6, 'Jamal Musiala', 'Midfielder', 10, '2003-02-26'),
(6, 'Florian Wirtz', 'Midfielder', 17, '2003-05-03'),
(6, 'Marc-Andre ter Stegen', 'Goalkeeper', 1, '1992-04-30'),
(7, 'Harry Kane', 'Forward', 9, '1993-07-28'),
(7, 'Jude Bellingham', 'Midfielder', 10, '2003-06-29'),
(7, 'Jordan Pickford', 'Goalkeeper', 1, '1994-03-07'),
(8, 'Lamine Yamal', 'Forward', 19, '2007-07-13'),
(8, 'Pedri', 'Midfielder', 20, '2002-11-25'),
(8, 'Unai Simon', 'Goalkeeper', 23, '1997-06-11');

INSERT INTO PlayerStats (stat_id, player_id, goals, assists, minutes_played) VALUES
(1, 1, 2, 1, 178),
(2, 4, 1, 0, 165),
(3, 7, 0, 2, 142),
(4, 10, 3, 1, 180),
(5, 13, 1, 1, 157),
(6, 16, 0, 0, 83),
(7, 19, 2, 0, 174),
(8, 22, 1, 0, 120);

INSERT INTO Referees (referee_id, name) VALUES
(1, 'Szymon Marciniak'),
(2, 'Michael Oliver'),
(3, 'Anthony Taylor'),
(4, 'Clement Turpin'),
(5, 'Danny Makkelie'),
(6, 'Daniele Orsato'),
(7, 'Facundo Tello'),
(8, 'Jesus Valenzuela');

INSERT INTO MatchResults
(result_id, match_id, team1_score, team2_score, winner_team_id) VALUES
(1, 1, 2, 0, 1),
(2, 2, 1, 3, 4),
(3, 3, 2, 2, NULL),
(4, 4, 1, 0, 7),
(5, 5, 2, 1, 1),
(6, 6, 0, 2, 4);
