#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICES (){

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  LIST_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$LIST_SERVICES" | while read SERVICE_ID NAME
  do
    NAME_FORMATTED=$(echo $NAME | sed 's/..//')
    echo "$SERVICE_ID) $NAME_FORMATTED" 
  done

  read SERVICE_ID_SELECTED
  
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
  then
    SERVICES "I could not find that service. What would you like today?"
  else
    SERVICE $SERVICE_ID_SELECTED $SERVICE_NAME
  fi
}

SERVICE (){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID_FORMATED=$(echo $CUSTOMER_ID | sed 's/ *//')
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID_FORMATED, $1)")

  echo -e "I have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."

}

echo -e "Welcome to My Salon, how can I help you?\n"
SERVICES