#!/bin/bash

# Init script variables
. ./variables.sh

az group create --name $rgName --location $location
az deployment group create --resource-group $rgName --template-uri $templateLocation

# Get ObjectId for user
 az ad user show --id "johnl@delta-n.nl" --query "objectId"

# Generate password
password=$(openssl rand -base64 10)