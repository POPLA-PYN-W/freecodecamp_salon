#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]];then
    echo -e "\n$1"
  fi
# select data + to read a data using while loop + show the data
SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
    echo "$SERVICE_ID) $SERVICE_NAME"
done
# read (input) data + check if condition
read SERVICE_ID_SELECTED
SERVICES_AVAILABLE_OUTPUT=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
SERVICES_AVAILABLE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
# check if  $ has an value
if [[ -z $SERVICES_AVAILABLE_OUTPUT ]];then
    MAIN_MENU "I could not find that service. What would you like today?"    
else
    echo "What's your phone number?"
    read CUSTOMER_PHONE
 
    CHECK_CUSTOMERS_PHONE=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    MAKE_APPOINTMENT(){
      # select data
      CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      SERV_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      # create a  2 format sed
      FORMAT_CUST_NAME=$(echo "$CUST_NAME" | sed  's/\s//g' -E)
      FORMAT_SERVICES_AVAILABLE_NAME=$(echo $SERVICES_AVAILABLE_NAME | sed 's/\s//g' -E)
      echo -e "\nWhat time would you like your $FORMAT_SERVICES_AVAILABLE_NAME , $FORMAT_CUST_NAME ?"
      read SERVICE_TIME
      APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUST_ID, '$SERVICE_TIME', $SERV_ID)")
      echo -e "\nI have put you down for a $FORMAT_SERVICES_AVAILABLE_NAME at $SERVICE_TIME, $FORMAT_CUST_NAME."
    }


  if [[ -z $CHECK_CUSTOMERS_PHONE ]];then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    NEW_CUSTOMER_LIST=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    MAKE_APPOINTMENT
    else
    MAKE_APPOINTMENT
  fi
fi

}
MAIN_MENU