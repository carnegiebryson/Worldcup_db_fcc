#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE games, teams")"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  #check for heading row and don't read in 
  if [[ $WINNER != "winner" ]]
  then
  # Add each unique team to teams table (24)
  # check for existing team id 
    #for winner
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  # if team id not found
    if [[ -z $WINNER_ID ]]
    then
    # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ INSERT_TEAM_RESULT = "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
      # get new team id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi
    
    # for opponent (loser)
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    # if team id not found
    if [[ -z $OPPONENT_ID ]]
    then 
    # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ INSERT_TEAM_RESULT = "INSERT 0 1" ]]
      then 
        echo Inserted into teams, $OPPONENT
      fi
      # get new team id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi
    # Insert a row for each line in the games.csv (32)
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ INSERT_GAME_RESULT = "INSERT 0 1" ]]
    then 
      echo Inserted into games: $YEAR $WINNER vs. $OPPONENT
    fi
  fi
done    
