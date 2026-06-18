NBA DATA ANALYSIS
Personal SQL Project
Analyzing trends, team performance, and draft success across NBA history ending at the 2022 NBA Season

Project Overview
This project uses a large database of NBA data that spans from the early 1950s to 2022. I wrote SQL queries to explore trends, patterns and outcomes using the historical data in the database. Each query was written in order to answer questions about the NBA or teams within the league. The results of the queries higlight how team stratigies correlate with winning, how the game has evolved over time, and which teams are finding more success over time. 

Database & Schema
The Project focuses on queries from three tables

game — Regular season and playoff game results with box score stats for home and away teams
draft_history — Every NBA draft pick with team, year, and player identifier
common_player_info — Player career metadata including college, seasons played, and legacy flags

A JOIN between draft_history and common_player_info on person_id enables analysis of how draft decisions translate into career outcomes.

Analysis 1: Average Scoring by Decade
Question
How has average scoring per game changed across NBA history?
Approach
The season_id field encodes the season year, so a SUBSTRING and CAST operation extracts the year for bucketing into decades. Average home points, away points, and combined total are aggregated per decade for regular season games only.
Key Findings
Scoring peaked in the 1960s (228.4 pts/game) during the high-tempo, pre-shot-clock era of Wilt Chamberlain and Bill Russell.
The 1990s and 2000s saw a defensive era dip — combined scoring fell below 200 pts/game.
The 2020s are trending back toward 1960s levels (225.0 pts/game), driven by the three-point revolution and pace-and-space offenses.




Analysis 2: How Games Are Decided
Question
What percentage of NBA games are decided by a close margin vs. a blowout?
Approach
Play-by-play data is used to identify the final score margin for each game. The scoremargin field at the end of regulation (period 4) is extracted, with TIE handled as a special case. Games are bucketed into four margin categories.
Key Findings
Nearly 69% of all NBA games end as blowouts (10+ point margin) — far more than casual fans might expect.
Truly last-second games (1-3 pts) represent less than 1% of the dataset, reflecting how rare the nail-biters really are.
Combined, games decided within 6 points make up only about 8% of the sample.




Analysis 3: Close Game Performance
Question
Which franchises have historically performed best in close games (decided by 5 points or fewer)?
Approach
Home games where the point differential was 5 or fewer are isolated. Win percentage in those games is calculated per franchise, with a minimum threshold of 100 close games to ensure statistical reliability.
Key Findings
The Boston Celtics lead all franchises with a 61.7% win rate in close games — consistent with their culture of clutch performance.
The Lakers and Bulls follow closely, reflecting the impact of elite closers (Kobe, Jordan) on late-game outcomes.
Close-game win rate appears to track franchise culture and star power more than raw talent.




Analysis 4: Three-Point Volume vs. Winning
Question
Do teams that shoot more three-pointers win more games?
Approach
Home team three-point attempts and shooting percentage are averaged per franchise across regular season games. Teams are bucketed into High, Medium, and Low volume shooters, and win percentage is ranked alongside three-point rank to surface any correlation.
Key Findings
Three-point volume alone does not guarantee wins — Charlotte shoots the most threes but ranks near the bottom in win percentage.
Efficiency matters more: the Clippers and Warriors combine medium-to-high volume with top accuracy, producing top-tier win rates.
The data suggests three-point shooting is a necessary but not sufficient condition for sustained success.




Analysis 5: Turnovers & Winning
Question
Which teams commit the fewest turnovers and does ball security correlate with winning?
Approach
Average turnovers per home game and home win percentage are calculated per team, then ranked independently using window functions. Comparing the two rankings surfaces whether low-turnover teams tend to be high-win teams.
Key Findings
The San Antonio Spurs rank 4th in fewest turnovers but 1st in home win percentage — suggesting ball security is a core pillar of their sustained excellence.
Charlotte ranks 1st in fewest turnovers but near last in wins, indicating turnovers alone don't explain outcomes.
The correlation is real but noisy — elite teams (Spurs, Mavs) benefit most from turnover discipline.




Analysis 6: Draft Success by Franchise
Question
Which franchises have historically developed their draft picks most effectively?
Approach
Draft history is joined to player career data. Metrics include the percentage of picks who played in the league, average career length, number of top-75 all-time players produced, and late-round gems (picks after #30 who played 5+ seasons).
Key Findings
The Rockets stand out for late-round development, producing 20 late-round gems — more than any franchise in the sample.
The Kings have the highest average career length (7.5 seasons) despite not producing top-75 players, suggesting consistent but not elite development.
All four franchises shown achieved 100% of their picks playing at least one game, which reflects the data joining methodology.




Analysis 7: College Program Pipelines
Question
Which college programs have produced the most NBA talent, and how do those players fare career-wise?
Approach
common_player_info is joined to draft_history and grouped by college. Metrics include total players drafted, average career length, and number of players on the NBA's 75th Anniversary Team.
Key Findings
Kentucky leads in raw draft volume (73 players) but produces fewer top-75 players relative to size than North Carolina (3) or UCLA (4).
North Carolina players average the longest careers at 8.0 seasons — reflecting the program's emphasis on NBA-ready fundamentals.
Kansas and Michigan State also stand out for career longevity, averaging 7.6 and 7.0 seasons respectively.



Notes
Database: MySQL with a custom NBA schema derived from publicly available play-by-play and roster datasets
All queries filter to the 30 current NBA franchises using team_abbreviation allowlists to exclude historical defunct teams
Window functions (RANK() OVER, SUM() OVER) are used in several queries to produce comparative rankings without subqueries
Regular season games only, unless otherwise noted; playoff data excluded to avoid distortion from small sample series
The play-by-play table is used for game margin analysis; all other queries run against the game and draft tables










