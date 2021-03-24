#!/bin/bash
set -xe # help set

header() { printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@" 
}

success() { printf "${green}✔ %s${reset}\n" "$@"
}

create_serviceprincipal () {    
    SPN_NAME=$1
    KEYVAULT_NAME=$2
    KEYVAULT_KEYNAME_SPN_ID=$3
    KEYVAULT_KEYNAME_SPN_PASSWORD=$4

    # See in AAD
    SPN_ID=$(az ad sp list --spn "http://$SPN_NAME" --query [].appId -o tsv)
    # See in Keyvault
    KV_ID=$(az keyvault secret list --vault-name $KEYVAULT_NAME --query "[?ends_with(id, '$KEYVAULT_KEYNAME_SPN_ID')].id" -o tsv)
    
    if [ -z "$SPN_ID" ] || [ -z "$KV_ID" ]; then
        
        SPN_PASSWORD=$(az ad sp create-for-rbac --skip-assignment --name "http://$SPN_NAME" --query password --output tsv)
        az keyvault secret set --vault-name $KEYVAULT_NAME --name $KEYVAULT_KEYNAME_SPN_PASSWORD --value $SPN_PASSWORD
        
        SPN_ID=$(az ad sp show --id http://$SPN_NAME --query appId --output tsv)
        az keyvault secret set --vault-name $KEYVAULT_NAME --name $KEYVAULT_KEYNAME_SPN_ID --value $SPN_ID
        
        sleep 30
        echo "SPN $SPN_NAME created"
    else
        echo "SPN $SPN_NAME already exists"
    fi    
}

get_objectid () {
    local user_arg=$1

    if [ -z "$user_arg" ]; then
        echo "User argument not found."
        exit 1
    fi

    az ad user show --id $1 --query "objectId"
}

generate_password () {
    local length_arg=$1

    if ! command -v openssl &> /dev/null; then
        echo "OpenSSL command was not found."
        exit 1
    fi

    if [ -z "$length_arg" ]; then
        local length_arg=10
    fi

    openssl rand -base64 $length_arg
}

# Reset debugger
set +xe
