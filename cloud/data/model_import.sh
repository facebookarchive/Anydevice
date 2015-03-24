#!/bin/bash
# model_import.sh
#
# This script creates a new Model object for the CC3200 device and uploads it
# to the Parse application. Since the Model class has an icon field, this script
# takes the icon file path as a command line argument. The uploaded icon file
# will be named 'cc3200.png' on Parse.com.

# Function to extract http status from response and validate it. Takes an error
# message as a parameter.
function handle_http_status() {
  # Extract the status code from the response.
  statusCodePattern='([0-9]{3})'
  statusCodePair=$(grep -oE "\"status\":$statusCodePattern" <<< $httpResponse)
  statusCode=$(grep -oE $statusCodePattern <<< $statusCodePair)

  # If status code is not 201, the request failed. Echo the error message.
  if [ $statusCode -ne 201 ]; then
      echo "$1"
      exit 1
  fi
}

# Function which extracts the value of a JSON key from the global.json file. The
# desired JSON key is provided as a parameter.
function get_parse_key() {
  keyName=$1

  # Assume values will be alphanumeric strings.
  valuePattern='[0-9a-zA-Z]+'

  # Find the key/value string.
  keyPair=$(grep -oE "(\"$keyName\": \"$valuePattern\")" <<< $configData)

  # Remove the key part by taking the string after the colon.
  key=$(grep -oE ":.*" <<< $keyPair)

  # Extract the value by removing the colon and quotes.
  key=$(grep -oE $valuePattern <<< $key)
}


# Ensure the icon file name has been passed as an argument.
if [ $# -eq 0 ]; then
  echo "Usage: ./model_import.sh filename"
  exit 1
fi

# Load the global.json file into a variable.
configData=$(cat ../config/global.json)

# Find the Parse Application ID.
get_parse_key "applicationId"
parseApplicationId=$key

# Get Parse REST API Key.
parseRestAPIKey=$2
#get_parse_key "restApiKey"
#parseRestAPIKey=$key

# If the Parse Application ID was not extracted successfully, exit.
if [ "$parseApplicationId" == "" ]; then
  echo "The Parse Application ID could not be found in global.json."
  exit 1
fi

# If the Parse REST API Key was not extracted successfully, exit.
if [ "$parseRestAPIKey" == "" ]; then
  echo "You must pass your Parse REST API key as the second parameter to this script."
  exit 1
fi

# Extract the icon file name provided as a command line argument.
iconFileName=$1


# Silent cURL request to upload the icon image file to Parse.
httpResponse=$( curl -s -w "\"status\":%{http_code}" -X POST \
    -H "X-Parse-Application-Id: $parseApplicationId" \
    -H "X-Parse-REST-API-Key: $parseRestAPIKey" \
    -H "Content-Type: image/png" --data-binary "@$iconFileName" \
    https://api.parse.com/1/files/cc3200.png )

# Check the status code and provide an appropriate failure message.
handle_http_status "Failed to upload image. Exiting."

# Extract the icon name from the response.
namePattern='([^\"]*\.png)'
namePair=$(grep -oE "\"name\":\"$namePattern\"" <<< $httpResponse)
name=$(grep -oE $namePattern <<< $namePair)

# Extract the icon url from the response.
urlPattern='(https?:\/\/.*\.png)'
urlPair=$(grep -oE "\"url\":\"$urlPattern\"" <<< $httpResponse)
url=$(grep -oE $urlPattern <<< $urlPair)

# Create JSON which describes the new Model object.
modelJSON=$"{
                \"appName\": \"fbdr000001a\",
                \"boardType\": \"TI CC3200\",
                \"default\": true,
                \"icon\": {
                    \"__type\": \"File\",
                    \"name\": \"$name\",
                    \"url\": \"$url\"
                }
            }"

# Import the new Model object into the Parse application.
httpResponse=$( curl -s -w "\"status\":%{http_code}" -X POST \
  -H "X-Parse-Application-Id: $parseApplicationId" \
  -H "X-Parse-REST-API-Key: $parseRestAPIKey" \
  -H "Content-Type: application/json" \
  -d "$modelJSON" \
  https://api.parse.com/1/classes/Model )

# Check the status code and provide an appropriate failure message.
handle_http_status "Failed to import the data. Exiting."

# Done. Echo a success message.
echo "Model class created successfully."
