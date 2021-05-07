source ./variables-bicep.sh
source ../../utils.sh

password=$(generate_password 10)

header "Creating resource group"
az group create --name $rgName --location $location

header "Deploying Bicep file"
az deployment group create \
    --name bicep-deployment \
    --resource-group $rgName \
    --template-file ..\virtualMachine.bicep \
    --parameters adminPassword="$password"