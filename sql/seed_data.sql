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
