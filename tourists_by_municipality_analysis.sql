SHOW TABLES;

-- Selecting data
SELECT *
FROM municipality;

SELECT *
FROM tourists_by_municipality;

-- Total number of foreign tourists by municipality in the last 10 years
SELECT 
    name,
    SUM(arrivals_foreign) AS total_foreign_visitors,
    SUM(nights_foreign) AS total_foreign_overnighs
FROM tourists_by_municipality AS t
JOIN municipality AS m
ON t.municipality_id = m.id
GROUP BY name
ORDER BY total_foreign_visitors DESC;

-- Showing growth rate of each municaplity by year
CREATE VIEW v1 AS(
SELECT 
	year,
    name,
    SUM(arrivals_foreign) AS total_foreign_visitors,
    LAG(SUM(arrivals_foreign)) OVER(PARTITION BY name ORDER BY year) as prev_year,
    SUM(nights_foreign) AS total_overnight_visitors,
	LAG(SUM(nights_foreign)) OVER(PARTITION BY name ORDER BY year) as prev_year_nights
FROM tourists_by_municipality AS t
JOIN municipality AS m
ON t.municipality_id = m.id
GROUP BY year, name );

-- Average number of foreign tourists who visited each city in the last 10 years
SELECT 
	name,
    ROUND(AVG(total_foreign_visitors), 2) as average_visit
FROM v1
GROUP BY name
ORDER BY average_visit DESC;

-- Growth by city every year
SELECT
	year,
    name,
    total_foreign_visitors,
    prev_year,
    CONCAT(ROUND((total_foreign_visitors - prev_year) / prev_year * 100, 2), '%') as growth
FROM v1;

-- Average growth by municipality over ten years
WITH t2 AS (
SELECT
	year,
    name,
    total_foreign_visitors,
    prev_year,
    ROUND((total_foreign_visitors - prev_year) / prev_year * 100, 2) as growth
FROM v1
)
SELECT
	name,
    ROUND(AVG(growth), 2) AS average_growth
FROM t2
GROUP BY name
ORDER BY average_growth DESC;

-- Total number of nights by foreign visitors in the last 10 years
SELECT 
	SUM(total_overnight_visitors) AS total_foreign_overnights
FROM v1;

-- Total number of nights tourists spent in each municipality
SELECT
	name,
    SUM(total_overnight_visitors) AS total_foreign_overnights
FROM v1
GROUP BY name
ORDER BY total_foreign_overnights DESC;

-- Average time(nights) foreign tourists spent in each city in the last decade
SELECT
	name,
    ROUND(AVG(total_overnight_visitors), 2) AS average_stay
FROM v1
GROUP BY name
ORDER BY average_stay DESC;

-- Growth by amount of time(nights) tourists spend in each city by year
SELECT
	year,
    name,
    CONCAT(ROUND((total_overnight_visitors - prev_year_nights) / prev_year_nights * 100, 2), '%') AS growth
FROM v1;

-- Cities who have the biggest growth in the last 10 years in number of stays by foreign tourists
SELECT
	name,
    ROUND(AVG((total_overnight_visitors - prev_year_nights) / prev_year_nights * 100), 2) AS average_growth
FROM v1
GROUP BY name
ORDER BY average_growth DESC;

-- How many nights does the tourist on average stay in the city?
SELECT 
	name,
    ROUND((total_overnight_visitors / total_foreign_visitors), 2) as average_stay_by_visitor
FROM v1
GROUP BY name
ORDER BY average_stay_by_visitor DESC;

-- Analyzing domestic tourists

-- Joining the two tables based on municipality id
SELECT
	 *
FROM tourists_by_municipality AS t
JOIN municipality AS m
ON t.municipality_id = m.id;

-- Creating a view that has summed values
CREATE VIEW v2 AS (
SELECT
	 year,
     name,
     arrivals_domestic,
     LAG(arrivals_domestic) OVER(PARTITION BY name ORDER BY year) as prev_year,
     nights_domestic,
	 LAG(nights_domestic) OVER(PARTITION BY name ORDER BY year) as prev_year_nights
FROM tourists_by_municipality AS t
JOIN municipality AS m
ON t.municipality_id = m.id
);

-- Total number of domestic visitors over 10 years
SELECT 
	SUM(arrivals_domestic) AS total_domestic_visitors
FROM v2;

-- Total number of domestic visitors by city over 10 years
SELECT
	name,
	SUM(arrivals_domestic) AS total_domestic_visitors
FROM v2
GROUP BY name
ORDER BY total_domestic_visitors DESC;

-- Growing rate of visitors by each city through the years
SELECT
	year,
	name,
    ROUND((arrivals_domestic - prev_year) / prev_year, 2) AS growth
FROM v2;

-- Avrage growth rate by city over the decade by domestic arrivals
SELECT 
	name,
    ROUND(AVG((arrivals_domestic - prev_year) / prev_year), 2) AS average_growth
FROM v2
GROUP BY name
ORDER BY average_growth DESC;

-- Total number of time(stays) by domestic tourists
SELECT
	SUM(nights_domestic) AS total_nights_domestic
FROM v2;

-- Total number of time(stays) spent by domestic tourists  by city
SELECT
	name,
	SUM(nights_domestic) AS number_of_stays
FROM v2
GROUP BY name
ORDER BY number_of_stays DESC;

-- Average number of stays by domestic tourists by city
SELECT
	name,
    ROUND(AVG(nights_domestic), 2) AS average_stay
FROM v2
GROUP BY name
ORDER BY average_stay DESC;

-- Average stay by domestic tourist by city over 10 years

SELECT 
	name,
    ROUND(AVG(nights_domestic / arrivals_domestic), 2) AS average_stay
FROM v2
GROUP BY name
ORDER BY average_stay DESC;