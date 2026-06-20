WITH close_games AS (
    SELECT 
        g.team_name_home AS team, 
        g.wl_home, 
        g.pts_home, 
        g.pts_away
    FROM game g
    WHERE ABS(g.pts_home - g.pts_away) <= 5
    AND g.wl_home IS NOT NULL
    AND g.team_abbreviation_home IN (
        'ATL','BOS','BKN','CHA','CHI','CLE','DAL','DEN','DET','GSW',
        'HOU','IND','LAC','LAL','MEM','MIA','MIL','MIN','NOP','NYK',
        'OKC','ORL','PHI','PHX','POR','SAC','SAS','TOR','UTA','WAS'
    )
)
SELECT 
    team, 
    COUNT(*) AS close_games, 
    SUM(CASE WHEN wl_home = 'W' THEN 1 ELSE 0 END) AS wins, 
    ROUND(SUM(CASE WHEN wl_home = 'W' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS win_pct
FROM close_games
GROUP BY team
HAVING COUNT(*) >= 100
ORDER BY win_pct DESC;