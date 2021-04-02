#!/bin/bash

object_id=$1

# Init script variables
source ./variables.sh
source ./utils.sh

az group create --name $rgName --location $location

# Generate password
password=$(generate_password 10)

header "Validating ARM template"
validate_arm=$(az deployment group validate --resource-group $rgName --template-file $templateLocation --parameters $parameterLocation --parameters adminPassword=$password userObjectId=$object_id)
if $? -gt 0 &> /dev/null; then
    header "Exiting... validation failed."
    exit 1;
fi
echo "validation done - OK"

header "Deploying ARM template"
az deployment group create --resource-group $rgName --template-file $templateLocation --parameters $parameterLocation --parameters adminPassword=$password userObjectId=$object_id

# Add a two-way peering
az network vnet peering create --resource-group $rgName --name vnet0-vnet1-peering --vnet-name vmjohn-vnet0 --remote-vnet vmjohn-vnet1 --allow-vnet-access
az network vnet peering create --resource-group $rgName --name vnet1-vnet0-peering --vnet-name vmjohn-vnet1 --remote-vnet vmjohn-vnet0 --allow-vnet-access
