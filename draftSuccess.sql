USE nba_personal_project;
SELECT
    d.team_name,
    COUNT(*) AS total_picks,
    ROUND(SUM(CASE WHEN c.games_played_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_picks_who_played,
    ROUND(AVG(c.season_exp), 1) AS avg_seasons,
    SUM(CASE WHEN c.greatest_75_flag = 'Y' THEN 1 ELSE 0 END) AS top75_players,
    ROUND(AVG(d.overall_pick), 1) AS avg_pick_used,
    SUM(CASE WHEN d.overall_pick > 30 AND c.season_exp >= 5 THEN 1 ELSE 0 END) AS late_round_gems
FROM draft_history d
JOIN common_player_info c ON d.person_id = c.person_id
WHERE d.team_abbreviation IN (
    'ATL','BOS','BKN','CHA','CHI','CLE','DAL','DEN','DET','GSW',
    'HOU','IND','LAC','LAL','MEM','MIA','MIL','MIN','NOP','NYK',
    'OKC','ORL','PHI','PHX','POR','SAC','SAS','TOR','UTA','WAS'
)
GROUP BY d.team_name, d.team_abbreviation
HAVING COUNT(*) >= 10
ORDER BY avg_seasons DESC, late_round_gems DESC;