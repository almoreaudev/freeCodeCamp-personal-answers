#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

DISPLAY_ELEMENT() {
  #show the output for the element
  echo "$1" | while read AN BAR NAME BAR SYMBOL BAR TYPE BAR MASS BAR MELT BAR BOIL
  do
    echo "The element with atomic number $AN is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  done
}


if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  #Show with an atomix number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_AN=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties JOIN elements USING (atomic_number) JOIN types USING (type_id) WHERE atomic_number=$1")
    if [[ -z $ELEMENT_AN ]]
    then
      echo "I could not find that element in the database."

    else
      DISPLAY_ELEMENT "$ELEMENT_AN"
    fi
  #Show with a symbol or a name
  else
    ELEMENT_S=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties JOIN elements USING (atomic_number) JOIN types USING (type_id) WHERE symbol='$1'")
    if [[ -z $ELEMENT_S ]]
    then
      #test for name
      ELEMENT_N=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties JOIN elements USING (atomic_number) JOIN types USING (type_id) WHERE name='$1'")
      if [[ -z $ELEMENT_N ]]
      then
        echo "I could not find that element in the database."
      else
        DISPLAY_ELEMENT "$ELEMENT_N"
      fi
    else
      DISPLAY_ELEMENT "$ELEMENT_S"
    fi
  fi
fi
