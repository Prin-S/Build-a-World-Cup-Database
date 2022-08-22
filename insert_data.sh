#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    # Insert winners into 'teams' table
    W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    if [[ -z $W_TEAM_ID ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
        echo Inserted $WINNER
      fi

      W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Insert opponents into 'teams' table
    O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    if [[ -z $O_TEAM_ID ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        echo Inserted $OPPONENT
      fi

      O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Insert matches into 'games' table
    INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $W_TEAM_ID, $O_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

    if [[ $INSERT_INTO_GAMES == "INSERT 0 1" ]]
    then
      echo Inserted $YEAR $ROUND $W_TEAM_ID $O_TEAM_ID $WINNER_GOALS:$OPPONENT_GOALS
    fi
  fi

done
