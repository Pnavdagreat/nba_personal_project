WITH game_margins AS (
    SELECT
        game_id,
        period,
        CASE 
            WHEN scoremargin = 'TIE' THEN 0
            ELSE CAST(scoremargin AS SIGNED)
        END AS margin
    FROM play_by_play
    WHERE scoremargin IS NOT NULL 
    AND scoremargin != ''
),
final_margins AS (
    SELECT
        game_id,
        MAX(CASE WHEN period = 4 THEN ABS(margin) END) AS final_margin
    FROM game_margins
    GROUP BY game_id
)
SELECT
    CASE
        WHEN final_margin <= 3 THEN 'Last second (1-3 pts)'
        WHEN final_margin <= 6 THEN 'Close (4-6 pts)'
        WHEN final_margin <= 10 THEN 'Moderate (7-10 pts)'
        ELSE 'Blowout (10+ pts)'
    END AS game_type,
    COUNT(*) AS total_games,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_games
FROM final_margins
WHERE final_margin IS NOT NULL
GROUP BY game_type
ORDER BY MIN(final_margin);