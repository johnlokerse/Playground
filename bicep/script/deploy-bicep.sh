source ./variables-bicep.sh
source ../../utils.sh

az group create --name $rgName --location $location

password=$(generate_password 10)
echo $password