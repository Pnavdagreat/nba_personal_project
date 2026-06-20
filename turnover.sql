-- Q5: Which teams commit the fewest turnovers and does it correlate with winning?
WITH team_tov AS (
    SELECT
        team_name_home AS team,
        ROUND(AVG(tov_home), 1) AS avg_tov,
        ROUND(SUM(CASE WHEN wl_home = 'W' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS home_win_pct,
        COUNT(*) AS games
    FROM game
    WHERE tov_home IS NOT NULL
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
    avg_tov,
    home_win_pct,
    games,
    RANK() OVER (ORDER BY avg_tov ASC) AS tov_rank,
    RANK() OVER (ORDER BY home_win_pct DESC) AS win_rank
FROM team_tov
ORDER BY avg_tov ASC;