@minLength(3)
@maxLength(24)
param storageAccountName string = 'uniquestorage001'

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  location: resourceGroup().location
}
