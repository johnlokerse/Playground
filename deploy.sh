#!/bin/bash

# Init script variables
source ./variables.sh
source ./utils.sh

# az group create --name $rgName --location $location
# az deployment group create --resource-group $rgName --template-uri $templateLocation

# Get ObjectId for user
object_id=$(get_objectid "johnl@delta-n.nl")

# Generate password
password=$(generate_password 10)
