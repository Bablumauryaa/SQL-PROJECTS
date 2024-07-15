
create database mct_db;
use mct_db;
drop database mct_db;
CREATE TABLE NETFLIX (
    show_id VARCHAR(255),
    type VARCHAR(255),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(255),
    date_added VARCHAR(255),
    release_year INT,
    rating VARCHAR(50),
    duration int,
    listed_in TEXT,
    description TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Netflix.csv'
INTO TABLE NETFLIX
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description);



-- bablu maurya
-- q1.Write a query to list all titles with their show_id, title, and type.
SELECT show_id, title, type
FROM netflix;

-- bablu maurya
-- q2.Write a query to display all columns for titles that are Movies.
SELECT *
FROM netflix
WHERE type = 'Movie';

-- bablu maurya
-- 3. Write a query to list TV shows that were released in the year 2021.
SELECT *
FROM netflix
WHERE type = 'TV Show' AND release_year = 2021;

-- bablu maurya
-- 4. Write a query to find all titles where the description contains the word family.
SELECT *
FROM netflix
WHERE description LIKE '%family%';

-- bablu maurya
-- 5. Write a query to count the total number of titles in the dataset.
SELECT COUNT(*) AS total_titles
FROM netflix;

-- bablu maurya
-- 6. Write a query to find the average duration of all movies 
-- (in minutes, wherever the season is mentioned, consider 400 minutes per season). 
-- in this question at the time of data cleaning i converted season to min so here we have only min in the column 
SELECT AVG(duration) AS average_duration_minutes
FROM netflix
WHERE type = 'Movie';


-- bablu maurya
-- 7.Write a query to list the top 5 latest titles based on the date_added, sorted in descending order.
SELECT show_id, title, type, date_added
FROM (
    SELECT show_id, title, type, date_added,
           DENSE_RANK() OVER (ORDER BY date_added DESC) AS ranks
           FROM netflix
) AS ranked_titles
WHERE ranks <= 5;

-- bablu maurya
-- 8.Write a query to list all titles along with the number of other titles by the same director.
--  Include columns for show_id, title, director, and number_of_titles_by_director.
SELECT n1.show_id, n1.title, n1.director,
       (SELECT COUNT(n2.show_id) 
        FROM netflix n2 
        WHERE n2.director = n1.director) AS number_of_titles_by_director
FROM netflix n1
ORDER BY n1.show_id;


-- bablu maurya
-- 9.Write a query to find the total number of titles for each country. Display country and the count of titles.
SELECT country, COUNT(*) AS title_count
FROM netflix
where country <> ''
GROUP BY country
order by country;


-- bablu maurya
-- 10. Write a query using a CASE statement to categorize titles into three categories based on their rating: 
-- Family for ratings G, PG, PG-13, Kids for TV-Y, TV-Y7, TV-G, and Adult for all other ratings.
SELECT title, rating,
    CASE
        WHEN rating IN ('G', 'PG', 'PG-13') THEN 'Family'
        WHEN rating IN ('TV-Y', 'TV-Y7', 'TV-G') THEN 'Kids'
        ELSE 'Adult'
    END AS category
FROM netflix;


-- bablu maurya
-- 11. Write a query to add a new column title_length to the titles table that calculates the length of each title.
ALTER TABLE netflix
ADD COLUMN title_length INT;

UPDATE netflix
SET title_length = LENGTH(title);

set sql_safe_updates = 0;
select title , title_length from netflix;

-- bablu maurya
-- 12.Write a query using an advanced function to find the title with the longest duration in minutes.
SELECT title
FROM netflix
WHERE duration = (SELECT MAX(duration) FROM netflix );

-- bablu maurya
-- 13.  Create a view named RecentTitles that includes titles added in the last 30 days
CREATE VIEW RecentTitles AS
SELECT show_id, title, type, date_added
FROM netflix
WHERE  date_added >= DATE_SUB((SELECT MAX(date_added) FROM netflix), INTERVAL 30 DAY);
select * from RecentTitles;

-- bablu maurya
-- 14. Write a query using a window function to rank titles based on their release_year within each country.
SELECT show_id, title, release_year, country,
    RANK() OVER (PARTITION BY country ORDER BY release_year) AS release_year_rank
FROM netflix 
where country <> '';


-- bablu maurya
-- 15.Write a query to calculate the cumulative count of titles added each month sorted by date_added.
select month_added, monthly_title_count,
sum(monthly_title_count) over (order by month_added) as cumulative_count from(
SELECT DATE_FORMAT(date_added, '%Y-%m') AS month_added,
    COUNT(*) AS monthly_title_count
FROM netflix
GROUP BY DATE_FORMAT(date_added, '%Y-%m')
ORDER BY month_added) as asd;


-- bablu maurya
-- 16.Write a stored procedure to update the rating of a title given its show_id and new rating
delimiter // 
CREATE PROCEDURE UpdateRating( IN new_show_id varchar(255), IN new_rating VARCHAR(255) )
BEGIN
DECLARE countshow INT;
    SELECT COUNT(*) INTO countshow FROM netflix WHERE show_id = new_show_id;
    IF countshow = 0  THEN SELECT 'Error: Show ID does not exist' as errornotification;
    ELSE UPDATE netflix SET rating = new_rating WHERE show_id = new_show_id;
    select concat('rating updated success fully :- ' , new_show_id) as updatenotification;
    end if ;
END // delimiter ;
call UpdateRating ('s1','bablu');
select show_id,rating from netflix;


-- bablu maurya
-- 17.Write a query to find the country with the highest average rating for titles. 
-- Use subqueries and aggregate functions to achieve this.

SELECT country, round(AVG(rating_numeric),2) AS avg_rating
FROM ( SELECT n.country,
           CASE
               WHEN rating IN ('G', 'TV-Y') THEN 1
               WHEN rating IN ('PG', 'TV-Y7') THEN 2
               WHEN rating IN ('PG-13', 'TV-G') THEN 3
               ELSE 4
           END AS rating_numeric  
           FROM netflix n) AS rated_titles
GROUP BY country
ORDER BY avg_rating desc;



-- bablu maurya 
-- 18. Write a query to find pairs of titles from the same country where one title has a higher rating than the other. 
-- Display columns for show_id_1, title_1, rating_1, show_id_2, title_2, and rating_2.
SELECT n1.show_id AS show_id_1, n1.title AS title_1, n1.rating AS rating_1,
       n2.show_id AS show_id_2, n2.title AS title_2, n2.rating AS rating_2
FROM netflix n1
JOIN netflix n2 ON n1.country = n2.country
WHERE n1.title <> n2.title 
      AND CASE WHEN n1.rating = 'G' THEN 1  WHEN n1.rating = 'PG' THEN 2
        WHEN n1.rating = 'PG-13' THEN 3      WHEN n1.rating = 'R' THEN 4
	    WHEN n1.rating = 'NC-17' THEN 5   ELSE 0    END < 
          CASE  WHEN n2.rating = 'G' THEN 1    WHEN n2.rating = 'PG' THEN 2
                WHEN n2.rating = 'PG-13' THEN 3   WHEN n2.rating = 'R' THEN 4
                WHEN n2.rating = 'NC-17' THEN 5   ELSE 0      END
ORDER BY n1.country;
             