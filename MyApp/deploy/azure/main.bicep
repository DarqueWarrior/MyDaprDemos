targetScope = 'subscription'

param location string = 'eastus'
param rgName string = 'dapr_myapp_demo'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module myapp './myapp.bicep' = {
  name: 'myapp'
  scope: resourceGroup(rg.name)
  params: {
    location: location
  }
}

output storageAccountName string = myapp.outputs.storageAccountName

output serviceBusAuthRule string = myapp.outputs.serviceBusAuthRule
output serviceBusNamespace string = myapp.outputs.serviceBusNamespace
