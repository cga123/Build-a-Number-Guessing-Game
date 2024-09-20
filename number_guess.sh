#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
else
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Debug: GAMES_PLAYED = $GAMES_PLAYED, BEST_GAME = $BEST_GAME"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

GUESS_COUNT=0
while true; do
  read GUESS
  
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  ((GUESS_COUNT++))
  
  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

UPDATE_RESULT=$($PSQL "UPDATE users SET 
       games_played = games_played + 1, 
       best_game = CASE 
         WHEN best_game = 0 OR $GUESS_COUNT < best_game 
         THEN $GUESS_COUNT 
         ELSE best_game 
       END 
       WHERE username='$USERNAME'")
