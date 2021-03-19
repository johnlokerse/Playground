#!/bin/bash

# Init script variables
. ./variables.sh

az group create --name $rgName --location $location
az deployment group create --resource-group $rgName --template-uri $templateLocation