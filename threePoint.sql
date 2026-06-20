-- Q3: Do teams that shoot more 3-pointers win more games?
WITH three_pt_stats AS (
    SELECT
        team_name_home AS team,
        ROUND(AVG(fg3a_home), 1) AS avg_3pt_attempts,
        ROUND(AVG(fg3_pct_home), 3) AS avg_3pt_pct,
        ROUND(SUM(CASE WHEN wl_home = 'W' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS win_pct,
        COUNT(*) AS games
    FROM game
    WHERE fg3a_home IS NOT NULL
    AND wl_home IS NOT NULL
    AND season_type = 'Regular Season'
    AND team_abbreviation_home IN (
        'ATL','BOS','BKN','CHA','CHI','CLE','DAL','DEN','DET','GSW',
        'HOU','IND','LAC','LAL','MEM','MIA','MIL','MIN','NOP','NYK',
        'OKC','ORL','PHI','PHX','POR','SAC','SAS','TOR','UTA','WAS'
    )
    GROUP BY team
)
SELECT
    team,
    avg_3pt_attempts,
    avg_3pt_pct,
    win_pct,
    CASE
        WHEN avg_3pt_attempts >= 35 THEN 'High Volume (35+)'
        WHEN avg_3pt_attempts >= 25 THEN 'Medium Volume (25-34)'
        ELSE 'Low Volume (<25)'
    END AS shooting_style,
    RANK() OVER (ORDER BY avg_3pt_attempts DESC) AS three_pt_rank,
    RANK() OVER (ORDER BY win_pct DESC) AS win_rank
FROM three_pt_stats
ORDER BY avg_3pt_attempts DESC;