#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Erase existing database, reset sequences to 1
echo $($PSQL "TRUNCATE games, teams;")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1;")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;")

# Read CSV input
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
#cat gamestest.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Check it is not the first line
  if [[ $YEAR != "year" ]]
  then
    # Check if Winner exists
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      # If it does not exist, insert it
      if [[ -z $WINNER_ID ]]
      then
        INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
        # Check if insertion was successful
        if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
        then
          echo Inserted new team into teams, $WINNER
          #Assign the WINNER_ID for use in the games table insertion
          WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        fi
      fi
    # Check if Opponent exists
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      # If it does not exist, insert it
      if [[ -z $OPPONENT_ID ]]
      then
        INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
        # Check if insertion was successful
        if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
        then
          echo Inserted new team into teams, $OPPONENT
          #Assign the OPPONENT_ID for us in the games table insertion
          OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        fi
      fi

    # If they do exist, add an entry into games for them
    INSERT_ENTRY_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
  fi

done
