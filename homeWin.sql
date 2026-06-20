WITH season_wins AS (
    SELECT
        team_name_home AS team,
        CAST(SUBSTRING(season_id, 2) AS UNSIGNED) AS season_year,
        COUNT(*) AS home_games,
        ROUND(SUM(CASE WHEN wl_home = 'W' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS home_win_pct
    FROM game
    WHERE wl_home IS NOT NULL
    AND team_abbreviation_home IN (
        'ATL','BOS','BKN','CHA','CHI','CLE','DAL','DEN','DET','GSW',
        'HOU','IND','LAC','LAL','MEM','MIA','MIL','MIN','NOP','NYK',
        'OKC','ORL','PHI','PHX','POR','SAC','SAS','TOR','UTA','WAS'
    )
    GROUP BY team, season_year
)
SELECT
    team,
    season_year,
    home_win_pct,
    RANK() OVER (PARTITION BY season_year ORDER BY home_win_pct DESC) AS rank_that_season
FROM season_wins
ORDER BY season_year DESC, rank_that_season ASC;