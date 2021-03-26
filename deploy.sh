#!/bin/bash

# Init script variables
source ./variables.sh
source ./utils.sh

az group create --name $rgName --location $location

# Get ObjectId for user
object_id=$(get_objectid "johnl@delta-n.nl")

# Generate password
password=$(generate_password 10)

az deployment group create --resource-group $rgName --template-uri $templateLocation --parameters adminPassword=$password userObjectId=$object_id
