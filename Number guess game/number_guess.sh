#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess_game --tuples-only -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))

echo -e "\nEnter your username:"
read USERNAME_GIVEN

USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME_GIVEN'")

if [[ -z $USER ]]
then
  echo -e "\nWelcome, $USERNAME_GIVEN! It looks like this is your first time here."
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME_GIVEN')")
  USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME_GIVEN'")
else
  echo "$USER" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

NUMBER_OF_GUESS=1
NUMBER_IS_GUESS=false
echo -e "\n\nGuess the secret number between 1 and 1000:"

while ! $NUMBER_IS_GUESS
do
  read NUMBER_GUESS

  if [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
  then 
  echo -e "\nThat is not an integer, guess again:" 
  continue
  fi

  if [[ $NUMBER_GUESS == $RANDOM_NUMBER ]]
  then
    echo -e "\nYou guessed it in $NUMBER_OF_GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"

    echo "$USER" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
    do
      ((GAMES_PLAYED++))
      if [[ $BEST_GAME > $NUMBER_OF_GUESS ]] 
      then 
        BEST_GAME=$NUMBER_OF_GUESS 
      fi

      USER_UPDATE=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
    done

    NUMBER_IS_GUESS=true
  else
  ((NUMBER_OF_GUESS+=1))
    if [[ $NUMBER_GUESS > $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    else
      echo -e "\nIt's higher than that, guess again:"
    fi
  fi
  
done

