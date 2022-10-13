#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# enter username
echo -e "\nEnter your username:"
read USERNAME

# check username
LOOKUP_RESULT=$($PSQL "select games_played, best_game from users where username = '$USERNAME'")

if [[ -z $LOOKUP_RESULT ]]
then
  INSERT_RESULT=$($PSQL "insert into users(username) values('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  read GAMES_PLAYED BAR BEST_GAME <<< $(echo $LOOKUP_RESULT)
  # potential bug here
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
fi

# number guessing game starts
ANSWER=$(( $RANDOM % 1000 + 1 ))
GUESS=-1
CNT=1
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

while [[ $GUESS != $ANSWER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ $GUESS > $ANSWER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  else
    echo -e "\nIt's lower than that, guess again:"
  fi
  read GUESS
  CNT=$(( $CNT + 1 ))
done

echo -e "\nYou guessed it in $CNT tries. The secret number was $ANSWER. Nice job!"

# update best_game
if [[ -z $BEST_GAME ]] || [[ $CNT < $BEST_GAME ]]
then
  BEST_GAME=$CNT
fi

# save record to users database
UPDATE_RESULT=$($PSQL "update users set games_played = $(( $GAMES_PLAYED + 1 )), best_game = $BEST_GAME where username = '$USERNAME'")


