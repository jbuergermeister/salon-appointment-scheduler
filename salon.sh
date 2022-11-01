#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

READ_SERVICE "What can we do for you today?"

READ_CUSTOMER_PHONE "What's your phone number?"

READ_SERVICE_TIME "When do you want to come in for your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')?"

INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
if [[ -z INSERT_APPOINTMENT ]]
then
  MAIN_MENU "Something went wrong, please try again"
else
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
fi
}
FIND_CUSTOMER_NAME() {
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    if [[ -z $INSERT_CUSTOMER ]]
    then
      MAIN_MENU "Something went wrong, please try again"
    fi
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    MAIN_MENU "Something went wrong, please try again"
  fi
}
READ_SERVICE(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
echo "$SERVICES" | while read ID BAR SERVICE
do
  if [[ $ID =~ ^[0-9] ]]
  then
    echo -e "$ID) $SERVICE"
  fi
done

read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]+$  ]]
then
  READ_SERVICE "Please enter a valid number."
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [[ -z $SERVICE_NAME ]]
then
  READ_SERVICE "Invalid service ID, choose from the listed options"
fi
}

READ_CUSTOMER_PHONE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  read CUSTOMER_PHONE
  FIND_CUSTOMER_NAME
}

READ_SERVICE_TIME() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  read SERVICE_TIME

  if [[ -z $SERVICE_TIME ]]
  then
    READ_SERVICE_TIME "Please name a time"
  fi
}

MAIN_MENU "~~~ Welcome to our Salon ~~~"
