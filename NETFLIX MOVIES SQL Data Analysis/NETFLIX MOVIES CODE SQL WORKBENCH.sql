
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