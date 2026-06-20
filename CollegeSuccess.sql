SELECT
    c.school,
    COUNT(*) AS players_drafted,
    ROUND(AVG(c.season_exp), 1) AS avg_career_length,
    SUM(CASE WHEN c.greatest_75_flag = 'Y' THEN 1 ELSE 0 END) AS top75_players
FROM common_player_info c
JOIN draft_history d ON c.person_id = d.person_id
WHERE c.school IS NOT NULL AND c.school != ''
GROUP BY c.school
ORDER BY players_drafted DESC
LIMIT 15;