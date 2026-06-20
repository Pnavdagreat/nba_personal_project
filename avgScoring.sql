-- Q2: How has average scoring per game changed by decade?
SELECT
    CASE
        WHEN CAST(SUBSTRING(season_id, 2) AS UNSIGNED) BETWEEN 1946 AND 1959 THEN '1940s-50s'
        WHEN CAST(SUBSTRING(season_id, 2) AS UNSIGNED) BETWEEN 1960 AND 1969 THEN '1960s'
        WHEN CAST(SUBSTRING(season_id, 2) AS UNSIGNED) BETWEEN 1970 AND 1979 THEN '1970s'
        WHEN CAST(SUBSTRING(season_id, 2) AS UNSIGNED) BETWEEN 1980 AND 1989 THEN '1980s'
        WHEN CAST(SUBSTRING(season_id, 2) AS UNSIGNED) BETWEEN 1990 AND 1999 THEN '1990s'
        WHEN CAST(SUBSTRING(season_id, 2) AS UNSIGNED) BETWEEN 2000 AND 2009 THEN '2000s'
        WHEN CAST(SUBSTRING(season_id, 2) AS UNSIGNED) BETWEEN 2010 AND 2019 THEN '2010s'
        WHEN CAST(SUBSTRING(season_id, 2) AS UNSIGNED) >= 2020 THEN '2020s'
    END AS decade,
    COUNT(*) AS total_games,
    ROUND(AVG(pts_home), 1) AS avg_home_pts,
    ROUND(AVG(pts_away), 1) AS avg_away_pts,
    ROUND(AVG(pts_home + pts_away), 1) AS avg_total_pts_per_game
FROM game
WHERE pts_home IS NOT NULL
AND pts_away IS NOT NULL
AND season_type = 'Regular Season'
GROUP BY decade
ORDER BY decade ASC;