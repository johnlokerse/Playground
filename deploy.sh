#!/bin/bash

object_id=$1
vmName=$2
addressPrefix=$3

# Init script variables
source ./variables.sh
source ./utils.sh

az group create --name $rgName --location $location

# Generate password
password=$(generate_password 10)

echo $1
echo $2
echo $3

header "Validating ARM template"
validate_arm=$(az deployment group validate --resource-group $rgName --template-file $templateLocation --parameters prefix=$vmName adminPassword=$password userObjectId=$object_id vnetAddressPrefix=$addressPrefix)
if $? -gt 0 &> /dev/null; then
    header "Exiting... validation failed."
    exit 1;
fi
echo "validation done - OK"

header "Deploying ARM template"
az deployment group create --resource-group $rgName --template-file $templateLocation --parameters prefix=$vmName adminPassword=$password userObjectId=$object_id vnetAddressPrefix=$addressPrefix
