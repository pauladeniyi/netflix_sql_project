
---15 Business Questions --------------------
--1. Count the Number of Movies vs TV Shows
SELECT
	type,
	COUNT(type) AS content_count
FROM netflix
GROUP BY type

--2. Find the Most Common Rating for Movies and TV Shows
SELECT *
FROM
(
SELECT 
	type,
	rating,
	COUNT(rating) AS rating_count,
	RANK() OVER (PARTITION BY type ORDER BY COUNT(rating) DESC) AS ranking
FROM netflix
GROUP BY type, rating
) t
WHERE ranking = 1


--3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT 
	*
FROM netflix
WHERE type = 'Movie' AND release_year = 2020

-- 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT
UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
COUNT(*) AS content_count
FROM netflix
GROUP BY country
ORDER BY COUNT(*) DESC
LIMIT 5

5. Identify the Longest Movie

SELECT
	*,
	COALESCE(CAST(REPLACE(duration, 'min', '') AS INT), 0) AS new_duration
FROM netflix
WHERE type = 'Movie'
ORDER BY COALESCE(CAST(REPLACE(duration, 'min', '') AS INT), 0) DESC
LIMIT 1

-- 6. Find Content Added in the Last 5 Years
SELECT
	*
FROM netflix
WHERE CAST(date_added AS DATE) >= CURRENT_DATE - INTERVAL'5 Years'

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT
	*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'


-- 8. List All TV Shows with More Than 5 Seasons
SELECT
	*
FROM netflix
WHERE type = 'TV Show'
AND CAST(SPLIT_PART(duration,' ', 1) AS INT) > 5

-- 9. Count the Number of Content Items in Each Genre

SELECT 
DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
COUNT(*) AS number_of_content
FROM netflix
GROUP BY DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ',')))


-- 10.Find each year and the average numbers of content release in India on netflix.
WITH CTE_unique_country  AS(
	SELECT
	release_year,
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS unique_country
FROM netflix
),
CTE_year AS (
SELECT *
FROM CTE_unique_country
WHERE unique_country = 'India'
),
CTE_number_released AS
(
SELECT *,
COUNT(*) OVER (PARTITION BY unique_country ORDER BY release_year) AS number_released
FROM CTE_year
)
SELECT 
release_year,
AVG(number_released) AS average_per_year
FROM CTE_number_released
GROUP BY release_year


--11. List All Movies that are Documentaries
SELECT 
*
FROM netflix
WHERE type = 'Movie' AND listed_in LIKE '%Documentar%'


-- 12. Find All Content Without a Director
SELECT 
*
FROM netflix
WHERE director IS NULL

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT 
*
FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND CAST(date_added AS DATE ) >= CURRENT_DATE - INTERVAL '6 years'


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT
India_Actors,
COUNT(*) AS no_featured
FROM
(
SELECT
TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS India_Actors
FROM netflix
WHERE country = 'India') t
GROUP BY India_Actors
ORDER BY COUNT(*) DESC
LIMIT 10

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT *
FROM
(
SELECT 
	title,
	description,
	CASE 
		WHEN description ILIKE '% kill %' THEN 'X'
		WHEN description ILIKE '% violence %' THEN 'Y'
		ELSE NULL
	END	AS category
FROM netflix
)t
WHERE category IN ('X', 'Y')



