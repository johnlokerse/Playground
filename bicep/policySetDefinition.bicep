targetScope = 'managementGroup'

resource mgSandbox 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: 'my-sandbox-env'
  scope: tenant()
}

resource resPolicySet 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'policyset-sandbox-001'
  properties: {
    displayName: 'policyset-sandbox-001'
    description: 'A set of deny policies used for the Sandbox management group'
    policyDefinitions: [
      {
        policyDefinitionId: 'e56962a6-4747-49cd-b67b-bf8b01975c4c'
      }
      {
        policyDefinitionId: 'e765b5de-1225-4ba3-bd56-1ac6695af988'
      }
      {
        policyDefinitionId: 'cccc23c7-8427-4f53-ad12-b6a63eb452b3'
        parameters: {
          listOfAllowedSKUs: {
            value: [
              'Standard_A1_v2'
            ]
          }
        }
      }
    ]
  }
}
