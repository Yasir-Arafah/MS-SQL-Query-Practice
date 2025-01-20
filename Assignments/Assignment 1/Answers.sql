CREATE DATABASE ASSIGNMENT
USE ASSIGNMENT

CREATE TABLE ACTOR(
	id int NOT NULL PRIMARY KEY,
	fname varchar(20) NOT NULL,
	lname varchar(20) NOT NULL,
	gender varchar(10) NOT NULL


);

INSERT INTO ACTOR 
VALUES	(237782,'Kong','Kam','Male'),
		(769112,'Luna','Rio','Female'),
		(436515,'Lung','Shuan','Male'),
		(688158,'Lupita','Lara','Female'),
		(39097,'Lupo','Berkowitch','Male'),
		(66467,'Lupu','Buznea','Male'),
		(4147,'Luran','Ahmeti','Male'),
		(819104,'Luraina','Undershute','Female'),
		(612391,'Lurdes','Eloy','Female'),
		(656029,'Luree','Holmes','Female'),
		(354670,'Lute','Olson','Male'),
		(138631,'Luther','Elmore','Male'),
		(159594,'Lutz','Fremde','Male'),
		(121441,'Lux','Diamond','Male'),
		(574169,'Luz','Casal','Female'),
		(664161,'Lya','Jan','Female')


CREATE TABLE MOVIE(

	id int NOT NULL PRIMARY KEY,
	name varchar(50) NOT NULL,
	m_year date NOT NULL,
	m_rank float NOT NULL

);

INSERT INTO MOVIE 
VALUES	(198865,'Macbeth (1913)','1913-06-12',6.8),
		(238703,'Officer 444 (1926)','1926-08-17',7.8),
		(238704,'Officer 666 (1914)','1914-04-08',5.2),
		(238707,'Officer and a Duck An (1985)','1985-01-02',6.5),
		(238694,'Office Space (1991)','1991-01-01',7.9000000000000004),
		(312130,'Spy (1989)','1989-03-14',7.2),
		(354791,'Violated (1953)','1953-12-12',5.9)



CREATE TABLE DIRECTOR(

	id int NOT NULL PRIMARY KEY,
	fname varchar(20) NOT NULL,
	lname varchar(20) NOT NULL,

);

INSERT INTO DIRECTOR
VALUES	(27649,'Antonio','Gasset'),
		(51184,'Billy','Mason'),
		(87938,'Carlos','Zara'),
		(65723,'Carol','Reed'),
		(42113,'Gerald','Koll'),
		(75623,'Harald','Staff'),
		(68378,'Jacques','Roullet'),
		(28684,'Jean','Giono'),
		(28736,'Jean','Giraud'),
		(16367,'Kristen','Coury'),
		(86333,'Michael','Wolk')


CREATE TABLE CASTT(
	
	p_id int NOT NULL FOREIGN KEY REFERENCES ACTOR(id),
	m_id int NOT NULL FOREIGN KEY REFERENCES MOVIE(id),
	cast_role varchar(50) NOT NULL

);



INSERT INTO CASTT
VALUES	(237782,198865,'[Businessman]'),
		(769112,238703,'[Dr. Jim Morgan]'),
		(436515,238704,'[Gerald]'),
		(688158,238707,'[Medico forense]'),
		(39097,238694,'[Mr. Barrington]'),
		(66467,312130,'[Pedro]'),
		(4147,354791,'[Margallo]'),
		(819104,198865,'[Camera director]'),
		(612391,238703,'[Dr. Zetina]'),
		(656029,238704,'[Professor]'),
		(354670,238707,'[Owen James]'),
		(138631,238694,'[Timi the Boy]'),
		(159594,312130,'[Oncle de Tango]'),
		(121441,354791,'[Joshua Two Feathers]'),
		(574169,198865,'[Specialty Dancer]'),
		(664161,198865,'[Commentator]')



CREATE TABLE MOVIE_DIRECTOR(

	d_id int NOT NULL FOREIGN KEY REFERENCES DIRECTOR(id),
	m_id int NOT NULL FOREIGN KEY REFERENCES MOVIE(id)


);

INSERT INTO MOVIE_DIRECTOR
VALUES	(27649,198865),
		(51184,238703),
		(87938,238704),
		(65723,238704),
		(42113,238707),
		(75623,238694),
		(68378,312130),
		(28684,354791),
		(28736,238694),
		(16367,354791),
		(86333,238703)
 


--query 1


SELECT dir.id, fname, lname, dir.movie

FROM	(SELECT RES.director_id AS id, RES.movie_name AS movie

		FROM	(SELECT temp.d_id AS director_id, temp.name AS movie_name, m_year, 
				CASE

					WHEN (YEAR(m_year) % 4 = 0 OR YEAR(m_year) % 400 = 0) AND (YEAR(m_year) % 100 != 0) THEN 'leap_year'
					ELSE 'not_leap_year'

				END AS leap

				FROM	(SELECT MOVIE_DIRECTOR.d_id AS d_id, MOVIE_DIRECTOR.m_id AS m_id, MOVIE.name AS name, m_year
						FROM MOVIE_DIRECTOR
						JOIN
						MOVIE
						ON MOVIE.id = MOVIE_DIRECTOR.m_id) AS temp) AS RES

		WHERE RES.leap = 'leap_year') AS dir

JOIN

DIRECTOR

ON dir.id = DIRECTOR.id


--query 2

SELECT id, fname, lname, film_num

FROM	(SELECT d_id, COUNT(m_id) AS film_num
		FROM MOVIE_DIRECTOR
		GROUP BY d_id) AS temp
JOIN

DIRECTOR

ON temp.d_id = DIRECTOR.id

ORDER BY film_num ASC


--query 3

SELECT MOVIE.id, MOVIE.name, RES.l_cast
FROM MOVIE
JOIN


(SELECT m_id, COUNT(p_id) AS l_cast
FROM CASTT
GROUP BY m_id
HAVING COUNT(p_id) =	(SELECT  MAX(cast_count) 
						FROM	(SELECT m_id, COUNT(p_id) AS cast_count
								FROM CASTT
								GROUP BY m_id) AS temp)) AS RES

ON RES.m_id = MOVIE.id



--query 4


SELECT RES.p_id, COUNT(DISTINCT RES.d_id) AS worked
FROM	(SELECT p_id, CASTT.m_id, d_id
		FROM CASTT
		JOIN MOVIE_DIRECTOR
		ON CASTT.m_id = MOVIE_DIRECTOR.m_id) AS RES
GROUP BY RES.p_id
HAVING COUNT(DISTINCT RES.d_id) >= 10


--query 5

SELECT id, fname, lname
FROM ACTOR 
WHERE id IN	(SELECT p_id AS actor_id

			FROM	(SELECT id, m_year
					FROM MOVIE
					WHERE YEAR(m_year) < 1960) AS res
			JOIN

			CASTT

			ON res.id = CASTT.m_id)


--query 6


SELECT YEAR(m_year)/10*10  AS decade, COUNT(id) AS num_films
		FROM MOVIE
		GROUP BY YEAR(m_year)/10*10
		HAVING COUNT(id) =	(SELECT MAX(n_films)
							FROM	(SELECT YEAR(m_year)/10*10  AS decade, COUNT(id) AS n_films
									FROM MOVIE
									GROUP BY YEAR(m_year)/10*10) AS RES)


--query 7


SELECT TEMPONE.a_id AS actor_id
FROM
(SELECT RES.p_id AS a_id, COUNT(RES.m_id) AS n_movies
FROM 

(SELECT p_id, m_id, YEAR(m_year) AS m_year
FROM MOVIE
JOIN CASTT
ON MOVIE.id = CASTT.m_id) AS RES 
WHERE RES.m_year BETWEEN 1901 AND 1950
GROUP BY RES.p_id) AS TEMPONE 

INTERSECT

SELECT TEMPTWO.a_id AS actor_id
FROM

(SELECT TEMP.p_id AS a_id, COUNT(TEMP.m_id) AS n_movies
FROM 

(SELECT p_id, m_id, YEAR(m_year) AS m_year
FROM MOVIE
JOIN CASTT
ON MOVIE.id = CASTT.m_id) AS TEMP 
WHERE TEMP.m_year BETWEEN 1851 AND 1900
GROUP BY TEMP.p_id) AS TEMPTWO


--query 8

SELECT fname, lname
FROM ACTOR
WHERE id IN	(SELECT p_id
			FROM CASTT
			WHERE m_id =	(SELECT id
							FROM MOVIE
							WHERE name = 'Officer 444 (1926)'))


--query 9

SELECT m_id
FROM ACTOR
JOIN CASTT
ON ACTOR.id = CASTT.p_id
GROUP BY m_id
HAVING SUM(CASE WHEN ACTOR.gender = 'Female' THEN 1 ELSE 0 END) > SUM(CASE WHEN ACTOR.gender = 'Male' THEN 1 ELSE 0 END)

/*
SELECT m_id, gender, COUNT(gender) as n_g
FROM ACTOR
JOIN CASTT
ON ACTOR.id = CASTT.p_id
GROUP BY m_id, gender
ORDER BY m_id
*/


--query 10


SELECT actor_id, movie_id, debut_year
FROM ACTOR
JOIN


(SELECT CASTT.p_id AS actor_id, RES.m_id AS movie_id, debut_year
FROM CASTT
JOIN 


(SELECT p_id, m_id,  MIN(YEAR(m_year)) AS debut_year
FROM MOVIE
JOIN CASTT
ON MOVIE.id = CASTT.m_id
GROUP BY p_id, m_id) AS RES
ON CASTT.p_id = RES.p_id) AS TEMP
ON TEMP.actor_id = ACTOR.id
ORDER BY lname













