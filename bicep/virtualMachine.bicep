@description('Prefix of the resources')
@minLength(3)
@maxLength(5)
param prefixName string = 'vmjohn'

@allowed([
  'Standard_B1s'
])
@description('Sku size of the VM')
param skuVM string = 'Standard_B1s'

@secure()
@description('Administrator password VM')
param adminPassword string

var storageAccountName = concat(prefixName, 'sa')
var publicIPName = concat(prefixName, '-publicip')
var nsgName = concat(prefixName, '-nsg')
var vnetName = concat(prefixName, '-vnet')
var subnetName = concat(prefixName, '-subnet')
var nicName = concat(prefixName, '-nic')
var ipConfigName = concat(prefixName, '-ipconfig')

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: resourceGroup().location
  kind: 'StorageV2'
  tags: {
    'displayName': storageAccountName
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPName
  location: resourceGroup().location
  tags: {
    'displayName': publicIPName
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower(concat(prefixName))
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: nsgName
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'ssh'
        properties: {
          description: 'This rule open the port 22 for SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: resourceGroup().location
  dependsOn: [
    nsg
  ]
  tags: {
    'displayName': vnetName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: resourceGroup().location
  dependsOn: [
    pip
    vnet
  ]
  tags: {
    'displayName': nicName
  }
  properties: {
    ipConfigurations: [
      {
        name: ipConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: prefixName
  location: resourceGroup().location
  dependsOn: [
    nic
  ]
  tags: {
    'displayName': concat('virtualMachine-', prefixName)
  }
  properties: {
    hardwareProfile: {
      vmSize: skuVM
    }
    osProfile: {
      computerName: prefixName
      adminUsername: 'john'
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '20.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: concat(prefixName, '-OSDisk')
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: sa.properties.primaryEndpoints.blob
      }
    }
  }
}
