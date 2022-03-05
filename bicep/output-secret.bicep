var subId = ''
var rgName = 'rg-keyvault'

// Get the KeyVault reference using keyword existing
resource myKv 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: 'kv-john-2022'
  scope: resourceGroup(subId, rgName)
}

output mySecret string = myKv.getSecret('my-secret')
