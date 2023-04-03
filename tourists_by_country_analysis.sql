USE tourism_analysis_mne;


SELECT * 
FROM country;

SELECT *
FROM tourists_by_country;

-- How many tourists visited and stayed in MONtenegro each year
-- Creating temporary table which can be used multiple times
CREATE TEMPORARY TABLE summed_values
AS
SELECT 
    year, 
    SUM(arrivals) AS total_arrivals, 
    SUM(nights) AS total_nights
FROM tourists_by_country
GROUP BY year;


-- Most visited years
SELECT *
FROM summed_values
ORDER BY total_arrivals DESC;

-- Percentage change of tourists arrivals and nights OVER the years
SELECT 
    year, 
    total_arrivals,
    LAG(total_arrivals, 1) OVER() AS prev_year,
    ROUND((total_arrivals - LAG(total_arrivals) OVER()) / LAG(total_arrivals) OVER() * 100, 2) AS growth,
    total_nights,
    LAG(total_nights, 1) OVER() AS prev_year,
    ROUND((total_nights - LAG(total_nights) OVER()) / LAG(total_nights) OVER() * 100, 2) AS growth
FROM summed_values;

-- Average growth rate in the period of 10 years
SELECT
    '2012-2022' AS period,
    ROUND(AVG((total_arrivals - prev_total_arrivals) / prev_total_arrivals * 100), 2) AS AVG_percent_change_arrivals,
    ROUND(AVG((total_nights - prev_total_nights) / prev_total_nights * 100), 2) AS AVG_percent_change_nights
FROM ( 
    SELECT 
        year,
        total_arrivals,
        LAG(total_arrivals) OVER (ORDER BY year) AS prev_total_arrivals,
        total_nights,
        LAG(total_nights) OVER (ORDER BY year) AS prev_total_nights
    FROM summed_values
) AS x;

-- Total arrivals and nights by country and year sorted bASed ON total_arrivals
SELECT 
    year, 
    name, 
    SUM(arrivals) AS total_arrivals, 
    SUM(nights) AS total_nights
FROM tourists_by_country AS t
JOIN country AS c
ON t.country_id = c.id 
GROUP BY year, name
ORDER BY 1, 3 DESC;

-- Top ten tourists origin country every year
CREATE  VIEW t1 
AS (
	SELECT
		year, 
		name, 
		SUM(arrivals) AS total_arrivals, 
		SUM(nights) AS total_nights,
		DENSE_RANK() OVER(PARTITION BY year ORDER BY SUM(arrivals) DESC) AS rnk
	FROM tourists_by_country AS t
	JOIN country AS c
		ON t.country_id = c.id 
	GROUP BY year, name);

SELECT 
	t1.year, 
	name,
	total_arrivals,
	ROUND((total_arrivals/total) * 100, 2) AS prcnt_of_total 
FROM t1
JOIN  (SELECT year, SUM(arrivals) AS total FROM tourists_by_country GROUP BY year) AS t2
	ON t1.year = t2.year
WHERE rnk <= 10;

-- Most visitors by country in the lASt 10 years

SELECT
	name, 
	COUNT(year) AS num_of_times,
	SUM(total_arrivals) AS total_visitors
FROM t1
WHERE rnk <=10
GROUP BY name
ORDER BY num_of_times DESC;

-- Average stays and OVERnights by country

SELECT
	name,
	ROUND(AVG(total_arrivals), 2) AS AVG_arrivals,
	ROUND(AVG(total_nights), 2) AS AVG_OVERnights
FROM t1
GROUP BY name
ORDER BY AVG_arrivals desc;

-- Showing trend FROM countires that is going up 
WITH t2 AS (
	SELECT 
		year, 
        name, 
        total_arrivals,
		LAG(total_arrivals) OVER(PARTITION BY name ORDER BY year) AS prev_year,
		ROUND((total_arrivals - LAG(total_arrivals) OVER(PARTITION BY name ORDER BY year)) / LAG(total_arrivals) OVER(PARTITION BY name ORDER BY year) * 100, 2) AS growth
	FROM t1)
SELECT
	name,
	ROUND(AVG(growth), 2) AS AVG_growth
FROM t2
GROUP BY name
ORDER BY AVG_growth desc;

-- Average amount of stays by country
SELECT
	name, 
	floor(AVG(total_nights)) AS AVG_stay
FROM t1
GROUP BY name
ORDER BY AVG_stay desc;

-- Showing trend in OVERnight stays by country

WITH t2 AS (
	SELECT 
		year, 
        name, 
        total_nights,
		LAG(total_nights) OVER(PARTITION BY name ORDER BY year) AS prev_year,
		ROUND((total_nights - LAG(total_nights) OVER(PARTITION BY name ORDER BY year)) / LAG(total_nights) OVER(PARTITION BY name ORDER BY year) * 100, 2) AS growth
FROM t1)

SELECT
	name,
	ROUND(AVG(growth), 2) AS AVG_growth
FROM t2
GROUP BY name
ORDER BY AVG_growth DESC;

-- Average stay of tourists by country for every year
SELECT 
	year, 
	name,
	ROUND(AVG(total_nights/total_arrivals),2 ) AS AVG_stay
FROM t1
GROUP BY year, name;

-- Top ten countries in the last ten years with spending the most nights
WITH t2 AS (
	SELECT 
		year, 
		name,
		ROUND(AVG(total_nights/total_arrivals), 2) AS avg_stay
	FROM T1
	GROUP BY year, name
)

SELECT 
	name,
	ROUND(AVG(avg_stay), 2) AS ten_year_avg
FROM t2
GROUP BY name
ORDER BY ten_year_avg DESC
LIMIT 10;
