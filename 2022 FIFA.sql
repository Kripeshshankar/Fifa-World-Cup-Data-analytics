SELECT * FROM 2022fifa.2022_world_cup_matches;


/* How host country is performing in world cup*/
With CTE AS(
SELECT year,host_country,sum(total_win) as total_wins
FROM
(
SELECT cup.year,host_country,case when host_country=win_condition then 1 else 0 end as total_win
FROM world_cups cup
INNER JOIN world_cup_matches matches
ON (cup.Host_Country=matches.Home_Team OR cup.Host_Country=matches.Away_Team) and (cup.Year=matches.year)
) AS world
GROUP BY year,host_country
),
hosting AS
(
SELECT cup.year,host_country,count(Win_Condition) as total_matches_played
FROM world_cups cup
INNER JOIN world_cup_matches matches
ON (cup.Host_Country=matches.Home_Team OR cup.Host_Country=matches.Away_Team) and (cup.Year=matches.year)
GROUP BY cup.year,host_country
)

SELECT cte.year,cte.host_country,total_wins,total_matches_played
FROM CTE
inner join hosting
ON cte.year=hosting.year;


/* All countries performance and their win percentage in world cup*/
WITH match_played as (
SELECT home_team AS team,sum(play) as total_played
FROM
(
SELECT home_team,count(home_team) as play
FROM world_cup_matches
GROUP BY home_team
UNION ALL
SELECT away_team,count(away_team)
FROM world_cup_matches
GROUP BY away_team
) AS match_played
GROUP BY team
),
total_wins as(
SELECT win_condition,count(win_condition) as total_win
FROM world_cup_matches
GROUP BY Win_Condition
)
SELECT played.team,total_played,coalesce(total_win,0) as total_win,round(coalesce((total_win/total_played)*100,0),2) as win_percentage
FROM match_played played
LEFT JOIN total_wins wins
ON played.team=wins.win_condition
ORDER BY win_percentage;

/* Countries performance during the year 2022*/
WITH match_played as (
SELECT years,home_team AS team,sum(play) as total_played
FROM
(
SELECT  right(date,4) as years,home_team,count(home_team) as play
FROM international_matches
WHERE right(date,4)=2022
GROUP BY years,home_team
UNION ALL
SELECT  right(date,4) as years,away_team,count(away_team)
FROM international_matches
WHERE right(date,4)=2022
GROUP BY years,away_team
) AS match_played
GROUP BY team,years
),
total_wins as(
SELECT  right(date,4) dater,winner,count(winner) as total_win
FROM international_matches
WHERE right(date,4)=2022
GROUP BY dater,winner
)
SELECT played.team,total_played,coalesce(total_win,0) as total_win,round(coalesce((total_win/total_played)*100,0),2) as win_percentage
FROM match_played played
LEFT JOIN total_wins wins
ON played.team=wins.winner
ORDER BY win_percentage;


/*Most goals scored player in world cup*/
SELECT player,sum(world_cup_goals) as total_goals
from 2022_world_cup_squads
group by player
order by total_goals desc;
SELECT player,(sum(goals)/sum(caps))*100 as total_goals
from 2022_world_cup_squads
WHERE caps>50
group by player
order by total_goals desc;
SELECT club,sum(goals) as total_goals
FROM 2022_world_cup_squads
group by club
ORDER BY total_goals desc;


/*Countries having players more than 30 years old number*/
SELECT team,count(player) as total_players
FROM 2022_world_cup_squads
WHERE age>30
group by team
ORDER BY total_players DESC;

/*Countries having players less than 30 years old number*/
SELECT team,count(player) as total_players
FROM 2022_world_cup_squads
WHERE age<25
group by team
ORDER BY total_players DESC;

/*players having the most total_goals in international football with playing more than  200 matches*/
SELECT player,sum(goals) as total_goals
FROM 2022_world_cup_squads
GROUP BY player
ORDER BY total_goals DESC;

/* goals scored by each world cup*/
SELECT tournament,sum(home_goals+away_goals) as total_goals
FROM international_matches
GROUP BY tournament
ORDER BY total_goals DESC;

/* goals scored by each league players in the world cup*/
SELECT league,sum(goals) AS total_goals
FROM 2022_world_cup_squads
group by league
ORDER BY total_goals DESC;

/* goals scored by each club players in the world cup*/
SELECT club,sum(world_cup_Goals) AS total_goals
FROM 2022_world_cup_squads
group by club
ORDER BY total_goals DESC;

/* Most goals scored team in world cup*/
SELECT home_team,sum(goals) AS total
FROM
(
SELECT home_team,home_goals as goals
FROM world_cup_matches
UNION ALL
SELECT Away_Team,Away_Goals
FROM world_cup_matches
) AS matcher
GROUP BY Home_Team
ORDER BY total desc;


/* argentina record against opponent team of group stage with how many wins,loss and draw*/
WITH how AS
(
SELECT Argentina,Win
FROM
(
SELECT CASE WHEN winner='Argentina' THEN 'Mexico' END AS Argentina,COUNT(CASE  WHEN winner='Argentina' THEN 2  END) AS win
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Mexico' or Away_Team='Mexico')
group by Argentina
Having Argentina='Mexico'
)AS against_mexico
UNION ALL
SELECT Argentina,Win
FROM(
SELECT CASE WHEN winner='Argentina' THEN 'Poland' END AS Argentina,COUNT(CASE  WHEN winner='Argentina' THEN 2  END) AS win
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Poland' or Away_Team='Poland')
group by Argentina
Having Argentina='Poland'
) AS against_poland
UNION ALL
SELECT Argentina,Win
FROM
(
SELECT CASE WHEN winner='Argentina' THEN 'Saudi Arabia' END AS Argentina,COUNT(CASE  WHEN winner='Argentina' THEN 2  END) AS win
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Saudi Arabia'  or Away_Team='Saudi Arabia' )
group by Argentina
Having Argentina='Saudi Arabia' 
) AS against_saudi 
),
loss AS
(
SELECT argentina,loss
FROM 
(
SELECT CASE WHEN winner='Mexico' THEN 'Mexico' END AS Argentina,COUNT(CASE  WHEN winner='Mexico' THEN 2  END) AS loss
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Mexico'  or Away_Team='Mexico' )
group by Argentina
Having Argentina='Mexico'
) AS loss
UNION ALL
SELECT argentina,loss
FROM 
(
SELECT CASE WHEN winner='Poland' THEN 'Poland' END AS Argentina,COUNT(CASE  WHEN winner='Poland' THEN 2  END) AS loss
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Poland'  or Away_Team='Poland' )
group by Argentina
Having Argentina='Poland'
) AS loss_poland
UNION ALL
SELECT argentina,loss
FROM 
(
SELECT CASE WHEN winner='Saudi Arabia' THEN 'Saudi Arabia' END AS Argentina,COUNT(CASE  WHEN winner='Saudi Arabia' THEN 2  END) AS loss
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Saudi Arabia'  or Away_Team='Saudi Arabia' )
group by Argentina
Having Argentina='Saudi Arabia'
) AS loss_saudi
),
drawer as
(
SELECT argentina,draw
FROM 
(
SELECT CASE WHEN winner='Draw' THEN 'Mexico' END AS Argentina,COUNT(CASE  WHEN winner='Draw' THEN 2  END) AS draw
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Mexico'  or Away_Team='Mexico' )
group by Argentina
) AS draw
UNION ALL
SELECT argentina,draw
FROM 
(
SELECT CASE WHEN winner='Draw' THEN 'Poland' END AS Argentina,COUNT(CASE  WHEN winner='Draw' THEN 2  END) AS draw
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Poland'  or Away_Team='Poland' )
group by Argentina
) AS drawen
UNION ALL
SELECT argentina,draw
FROM 
(
SELECT CASE WHEN winner='Draw' THEN 'Saudi Arabia' END AS Argentina,COUNT(CASE  WHEN winner='Draw' THEN 2  END) AS draw
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND   (Home_Team='Saudi Arabia'  or Away_Team='Saudi Arabia' )
group by Argentina
) AS drawened
)
SELECT how.argentina,how.win,coalesce(loss.loss,0) as loss,drawer.draw
FROM how
left join loss
ON how.argentina=loss.argentina
LEFT JOIN drawer
ON how.argentina=drawer.argentina;


/*Argentina performance during each world cup*/
WITH Total_Win AS (
SELECT year,Win_Condition,count(Win_Condition) as total_win
from world_cup_matches
WHERE Win_Condition='Argentina'
GROUP BY year,Win_Condition
),
total_play AS(
SELECT year,count(*) as total_played
from world_cup_matches
WHERE Home_Team='Argentina' OR Away_Team='Argentina'
GROUP BY year
),
total_loss AS
(
SELECT year,count(Win_Condition) as total_loss
FROM world_cup_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND (Win_Condition<>'Argentina' and Win_Condition<>'Draw')
GROUP BY year
),
total_draw AS
(
SELECT year,count(Win_Condition) as total_draw
FROM world_cup_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND Win_Condition='Draw'
GROUP BY year
)
SELECT play.year,coalesce(total_win,0) win,coalesce(total_loss,0) as loss,coalesce(total_draw,0) as draw,total_played
FROM total_win win
RIGHT JOIN total_play play
ON win.year=play.year
LEFT JOIN total_loss loss
ON play.year=loss.year
LEFT JOIN total_draw draw
ON  draw.year=play.year;

/*Argentina performance in during world cup of different stages*/
WITH Total_Win AS (
SELECT stage,Win_Condition,count(Win_Condition) as total_win
from world_cup_matches
WHERE Win_Condition='Argentina'
GROUP BY stage,Win_Condition
),
total_play AS(
SELECT stage,count(*) as total_played
from world_cup_matches
WHERE Home_Team='Argentina' OR Away_Team='Argentina'
GROUP BY stage
),
total_loss AS
(
SELECT stage,count(Win_Condition) as total_loss
FROM world_cup_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND (Win_Condition<>'Argentina' AND Win_Condition<>'Draw')
GROUP BY stage
),
total_draw AS
(
SELECT stage,count(Win_Condition) as total_draw
FROM world_cup_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND Win_Condition='Draw' 
GROUP BY stage
)
SELECT play.stage,coalesce(total_win,0) win,coalesce(total_loss,0) as loss,coalesce(total_draw,0) as draw,total_played
FROM total_win win
RIGHT JOIN total_play play
ON win.stage=play.stage
LEFT JOIN total_loss loss
ON play.stage=loss.stage
LEFT JOIN total_draw draw
ON  draw.stage=play.stage;



/* Argentina goal record against world cup participating opponents in group stage */
With total_goals_conceded AS(
SELECT team,sum(total_goals) as total_goals_conceded
FROM(
SELECT CASE WHEN Home_Team='Mexico' OR  Away_Team='Mexico' THEN 'Mexico'  
            WHEN Home_Team='Poland' OR  Away_Team='Poland' THEN 'Poland'  
            WHEN Home_Team='Saudi Arabia' OR  Away_Team='Saudi Arabia' THEN 'Saudi Arabia' 
            END AS team , 
            CASE WHEN Home_Team='Mexico' THEN home_goals WHEN Away_Team='Mexico' THEN Away_goals
            WHEN Home_Team='Poland' THEN home_goals WHEN Away_Team='Poland' THEN Away_goals
            WHEN Home_Team='Saudi Arabia' THEN home_goals WHEN Away_Team='Saudi Arabia' THEN Away_goals 
            END AS total_goals
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND ((Home_Team='Poland' OR Away_Team='Poland') OR (Home_Team='Mexico' or Away_Team='Mexico')OR (Home_Team='Saudi Arabia'OR Away_Team='Saudi Arabia'))
) AS team 
GROUP BY team
),
 total_goals_scored
AS(
SELECT team,sum(total_goals) as total_goals_scored
FROM(
SELECT CASE WHEN Home_Team='Mexico' OR  Away_Team='Mexico' THEN 'Mexico'  
            WHEN Home_Team='Poland' OR  Away_Team='Poland' THEN 'Poland'  
            WHEN Home_Team='Saudi Arabia' OR  Away_Team='Saudi Arabia' THEN 'Saudi Arabia' 
            END AS team , 
            CASE WHEN Home_Team='Mexico' THEN Away_Goals WHEN Away_Team='Mexico' THEN Home_Goals
            WHEN Home_Team='Poland' THEN Away_Goals WHEN Away_Team='Poland' THEN Home_Goals
            WHEN Home_Team='Saudi Arabia' THEN Away_Goals WHEN Away_Team='Saudi Arabia' THEN Home_Goals
            END AS total_goals
FROM international_matches
WHERE (Home_Team='Argentina' OR Away_Team='Argentina') AND ((Home_Team='Poland' OR Away_Team='Poland') OR (Home_Team='Mexico' or Away_Team='Mexico')OR (Home_Team='Saudi Arabia'OR Away_Team='Saudi Arabia'))
) AS team 
GROUP BY team
)
SELECT concede.team as Argentina,total_goals_conceded,total_goals_scored
FROM total_goals_conceded concede
inner join total_goals_scored scored
ON concede.team=scored.team ;



