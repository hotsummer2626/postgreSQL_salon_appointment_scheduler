#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "select service_id, name from services;")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid service number."
  else
    SERVICE_SELECTED=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_SELECTED | sed 's/^ *//')
    
    if [[ -z $SERVICE_SELECTED ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    fi

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
    fi

    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *//')
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

    MAKE_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    if [[ $MAKE_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    fi
  fi
}

MAIN_MENU
