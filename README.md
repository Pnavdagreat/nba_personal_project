# 🏀 NBA Data Analysis — Personal SQL Project
![NBA Dashboard](dashboard.png)
Analyzing trends, team performance, and draft success across NBA history (1950s–2022).

---

## 📖 Project Overview

This project uses a large database of NBA data spanning from the early 1950s to 2022. I wrote SQL queries to explore trends, patterns, and outcomes using historical data. Each query was written to answer a specific question about the NBA or teams within the league. The results highlight how team strategies correlate with winning, how the game has evolved over time, and which teams have found the most success.

---

## 🗄️ Database & Schema

The project focuses on three primary tables:

| Table | Description |
|-------|-------------|
| `game` | Regular season game results with box score stats for home and away teams |
| `draft_history` | Every NBA draft pick with team, year, and player identifier |
| `common_player_info` | Player career metadata including college, seasons played, and legacy flags |

A `JOIN` between `draft_history` and `common_player_info` on `person_id` enables analysis of how draft decisions translate into career outcomes.

---

## 📊 Analyses

### 1. Average Scoring by Decade

**Question:** How has average scoring per game changed across NBA history?

**Approach:** The `season_id` field encodes the season year. A `SUBSTRING` and `CAST` operation extracts the year for bucketing into decades. Average home points, away points, and combined total are aggregated per decade for regular season games only.

**Key Findings:**
- Scoring peaked in the 1960s (228.4 pts/game) during the high-tempo era of Wilt Chamberlain and Bill Russell
- The 1990s–2000s saw a defensive dip — combined scoring fell below 200 pts/game
- The 2020s are trending back toward 1960s levels (225.0 pts/game), driven by pace-and-space offenses

| Decade | Total Games | Avg Home Pts | Avg Away Pts | Avg Total Pts |
|--------|-------------|--------------|--------------|---------------|
| 1940s–50s | 4,550 | 91.3 | 86.0 | 177.3 |
| 1960s | 3,080 | 116.1 | 112.2 | 228.4 |
| 1970s | 5,535 | 109.9 | 105.8 | 215.8 |
| 1980s | 9,676 | 111.3 | 106.7 | 218.1 |
| 1990s | 11,016 | 102.1 | 98.5 | 200.6 |
| 2000s | 12,136 | 98.9 | 95.6 | 194.5 |
| 2010s | 10,659 | 105.2 | 102.5 | 207.7 |
| 2020s | 3,540 | 113.4 | 111.6 | 225.0 |

<details>
<summary>View SQL</summary>

```sql
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
```

</details>

---

### 2. How Games Are Decided

**Question:** What percentage of NBA games are decided by a close margin vs. a blowout?

**Approach:** Play-by-play data identifies the final score margin for each game. The `scoremargin` field at end of regulation (period 4) is extracted, with `TIE` handled as a special case. Games are bucketed into four margin categories.

**Key Findings:**
- Nearly **69%** of all NBA games end as blowouts (10+ point margin) — far more than fans might expect
- Truly last-second games (1–3 pts) represent less than **1%** of the dataset
- Games decided within 6 points make up only about **8%** of the sample

| Game Type | Total Games | % of Games |
|-----------|-------------|------------|
| Last Second (1–3 pts) | 74 | 0.2% |
| Close (4–6 pts) | 2,426 | 8.1% |
| Moderate (7–10 pts) | 6,821 | 22.9% |
| Blowout (10+ pts) | 20,496 | 68.7% |

<details>
<summary>View SQL</summary>

```sql
WITH game_margins AS (
    SELECT
        game_id,
        period,
        CASE 
            WHEN scoremargin = 'TIE' THEN 0
            ELSE CAST(scoremargin AS SIGNED)
        END AS margin
    FROM play_by_play
    WHERE scoremargin IS NOT NULL AND scoremargin != ''
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
```

</details>

---

### 3. Close Game Performance

**Question:** Which franchises have historically performed best in close games (decided by 5 points or fewer)?

**Approach:** Home games with a point differential of 5 or fewer are isolated. Win percentage is calculated per franchise with a minimum of 100 close games for statistical reliability.

**Key Findings:**
- The **Boston Celtics** lead all franchises with a 61.7% win rate in close games
- The **Lakers** and **Bulls** follow closely, reflecting the impact of elite closers (Kobe, Jordan)
- Close-game win rate tracks franchise culture and star power more than raw roster talent

| Team | Close Games | Wins | Win % |
|------|-------------|------|-------|
| Boston Celtics | 891 | 550 | 61.7% |
| Los Angeles Lakers | 698 | 407 | 58.3% |
| Chicago Bulls | 648 | 374 | 57.7% |
| Portland Trail Blazers | 624 | 359 | 57.5% |

<details>
<summary>View SQL</summary>

```sql
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
```

</details>

---

### 4. Three-Point Volume vs. Winning

**Question:** Do teams that shoot more three-pointers win more games?

**Approach:** Home team three-point attempts and shooting percentage are averaged per franchise across regular season games. Teams are bucketed into High, Medium, and Low volume shooters, then win percentage is ranked alongside three-point rank to surface correlation.

**Key Findings:**
- Three-point **volume alone does not guarantee wins** — Charlotte shoots the most threes but ranks near the bottom in win %
- **Efficiency matters more**: the Clippers and Warriors combine solid volume with top accuracy
- Three-point shooting appears to be a necessary but not sufficient condition for sustained success

| Team | Avg 3PA | 3P% | Win % | Style |
|------|---------|-----|-------|-------|
| Charlotte Hornets | 30.9 | 35.1% | 50.8% | Medium |
| LA Clippers | 30.2 | 37.9% | 65.1% | Medium |
| Brooklyn Nets | 30.1 | 35.8% | 50.8% | Medium |
| Golden State Warriors | 29.8 | 38.0% | 72.3% | Medium |

<details>
<summary>View SQL</summary>

```sql
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
```

</details>

---

### 5. Turnovers & Winning

**Question:** Which teams commit the fewest turnovers and does ball security correlate with winning?

**Approach:** Average turnovers per home game and home win percentage are calculated per team, then ranked independently using window functions. Comparing the two rankings surfaces whether low-turnover teams tend to be high-win teams.

**Key Findings:**
- The **San Antonio Spurs** rank 4th in fewest turnovers but **1st in home win %** — ball security is a core pillar of their dynasty
- **Charlotte** ranks 1st in fewest turnovers but near last in wins, showing turnovers alone don't explain outcomes
- The correlation is real but noisy — elite teams benefit most from turnover discipline

| Team | Avg TOV | Home Win % | TOV Rank | Win Rank |
|------|---------|------------|----------|----------|
| Charlotte Hornets | 13.1 | 50.8% | 1 | 29 |
| Dallas Mavericks | 13.7 | 60.3% | 2 | 17 |
| Toronto Raptors | 13.7 | 56.1% | 2 | 22 |
| San Antonio Spurs | 13.8 | 72.6% | 4 | 1 |

<details>
<summary>View SQL</summary>

```sql
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
```

</details>

---

### 6. Draft Success by Franchise

**Question:** Which franchises have historically developed their draft picks most effectively?

**Approach:** Draft history is joined to player career data. Metrics include the percentage of picks who played in the league, average career length, number of top-75 all-time players produced, and late-round gems (picks after #30 who played 5+ seasons).

**Key Findings:**
- The **Rockets** stand out for late-round development, producing **20 late-round gems** — most in the sample
- The **Kings** have the highest average career length (7.5 seasons) despite no top-75 players
- Draft development varies widely — volume of picks doesn't predict player quality

| Team | Total Picks | % Played | Avg Seasons | Top 75 | Avg Pick | Late Gems |
|------|-------------|----------|-------------|--------|----------|-----------|
| Kings | 61 | 100.0% | 7.5 | 0 | 24.7 | 12 |
| Raptors | 29 | 100.0% | 7.4 | 0 | 21.1 | 2 |
| Clippers | 45 | 100.0% | 7.3 | 0 | 24.9 | 1 |
| Rockets | 76 | 100.0% | 7.0 | 0 | 30.2 | 20 |

<details>
<summary>View SQL</summary>

```sql
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
```

</details>

---

### 7. College Program Pipelines

**Question:** Which college programs have produced the most NBA talent, and how do those players fare career-wise?

**Approach:** `common_player_info` is joined to `draft_history` and grouped by college. Metrics include total players drafted, average career length, and number of players on the NBA's 75th Anniversary Team.

**Key Findings:**
- **Kentucky** leads in raw draft volume (73 players) but produces fewer top-75 players than UNC (3) or UCLA (4)
- **North Carolina** players average the longest careers at 8.0 seasons, reflecting a focus on NBA-ready fundamentals
- **Kansas** and **Michigan State** also stand out for career longevity (7.6 and 7.0 seasons respectively)

| School | Players Drafted | Avg Career (Seasons) | Top 75 Players |
|--------|----------------|----------------------|----------------|
| Kentucky | 73 | 6.3 | 1 |
| UCLA | 57 | 6.8 | 4 |
| Duke | 55 | 6.4 | 0 |
| North Carolina | 52 | 8.0 | 3 |
| Kansas | 47 | 7.6 | 2 |
| Arizona | 45 | 7.0 | 0 |
| Louisville | 44 | 5.4 | 1 |
| Indiana | 38 | 6.4 | 1 |

<details>
<summary>View SQL</summary>

```sql
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
```

</details>

---

## 🛠️ Technical Notes

- **Database:** MySQL with a custom NBA schema derived from publicly available play-by-play and roster datasets
- **Franchise filter:** All queries filter to the 30 current NBA franchises using `team_abbreviation` allowlists to exclude historical defunct teams
- **Window functions:** `RANK() OVER` and `SUM() OVER` are used for comparative rankings without subqueries
- **Scope:** Regular season games only; playoff data excluded to avoid small-sample distortion
- **Play-by-play:** Used for game margin analysis only; all other queries run against the `game` and `draft` tables

---

## 📁 File Structure

```
├── avgScoring.sql / avgScoring.csv         # Scoring trends by decade
├── GamesDecided.sql / gamesDecided.csv     # Game margin distribution
├── closegames.sql / closegames.csv         # Close game win rates by team
├── threePoint.sql / threePoint.csv         # Three-point volume vs. wins
├── turnover.sql / turnover.csv             # Turnovers and win correlation
├── draftSuccess.sql / draftSuccess.csv     # Draft development by franchise
└── CollegeSuccess.sql / CollegeSuccess.csv # College pipeline analysis
```
