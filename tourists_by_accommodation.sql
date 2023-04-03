SHOW TABLES;

SELECT * 
FROM accommodation;

SELECT *
FROM tourists_by_accommodation;

CREATE VIEW group_acc AS (
SELECT 
	year,
    type,
    arrivals_foreign,
    LAG(arrivals_foreign) OVER(PARTITION BY type ORDER BY year) as prev_arrivals_foreign,
    arrivals_domestic,
    LAG(arrivals_domestic) OVER(PARTITION BY type ORDER BY year) as prev_arrivals_domestic,
    nights_foreign,
    LAG(nights_foreign) OVER(PARTITION BY type ORDER BY year) as prev_nights_foreign,
    nights_domestic,
    LAG(nights_domestic) OVER(PARTITION BY type ORDER BY year) as prev_nights_domestic
FROM tourists_by_accommodation AS t
JOIN accommodation AS a
ON t.accommodation_id = a.id
WHERE type NOT LIKE '%Individualni%'
);

-- Most popular group accommodation by arrivals and nights spent by foreign tourists
SELECT 
	type,
	SUM(arrivals_foreign) AS summed_foreign_arrivals,
    SUM(nights_foreign) AS summed_foreign_nights
FROM group_acc
WHERE type NOT LIKE '%Kolektivni%'
GROUP BY type
ORDER BY summed_foreign_arrivals DESC;

-- Average stay for foreign toursit in group accommodation

SELECT 
	type,
	ROUND(AVG(nights_foreign / arrivals_foreign), 2) AS average_stay
FROM group_acc
WHERE type NOT LIKE '%Kolektivni%'
GROUP BY type
ORDER BY average_stay DESC;


-- Average growth of popularity foreign tourists
SELECT
	type,
	ROUND(AVG((arrivals_foreign - prev_arrivals_foreign) / prev_arrivals_foreign * 100), 2) AS avg_foreign_arrivals_growth,
    ROUND(AVG((nights_foreign - prev_nights_foreign) / prev_nights_foreign * 100), 2) AS avg_foreign_nights_growth
FROM group_acc
WHERE type NOT LIKE '%Kolektivni%'
GROUP BY type
ORDER BY avg_foreign_arrivals_growth DESC;

-- Most popular group accomodation by domestic tourists
SELECT 
	type,
	SUM(arrivals_domestic) AS summed_domestic_arrivals,
    SUM(nights_domestic) AS summed_domestic_nights
FROM group_acc
WHERE type NOT LIKE '%Kolektivni%'
GROUP BY type
ORDER BY summed_domestic_arrivals DESC;

-- Average stay for domestic toursit in group accommodation
SELECT 
	type,
	ROUND(AVG(nights_domestic / arrivals_domestic), 2) AS average_stay
FROM group_acc
WHERE type NOT LIKE '%Kolektivni%'
GROUP BY type
ORDER BY average_stay DESC;

-- Average growth of popularity domestic tourists
SELECT
	type,
	ROUND(AVG((arrivals_domestic - prev_arrivals_domestic) / prev_arrivals_domestic * 100), 2) AS avg_domestic_arrivals_growth,
    ROUND(AVG((nights_domestic - prev_nights_domestic) / prev_nights_domestic * 100), 2) AS avg_domestic_nights_growth
FROM group_acc
WHERE type NOT LIKE '%Kolektivni%'
GROUP BY type
ORDER BY avg_domestic_arrivals_growth DESC;