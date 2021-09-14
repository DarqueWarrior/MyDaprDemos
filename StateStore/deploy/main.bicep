targetScope = 'subscription'

param location string = 'eastus'
param rgName string = 'demoStateStore'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module stateStore './stateStore.bicep' = {
  name: 'stateStore'
  scope: resourceGroup(rg.name)
  params: {
    location: location
  }
}

output cosmosDbKey string = stateStore.outputs.cosmosDbKey
output cosmosDbEndpoint string = stateStore.outputs.cosmosDbEndpoint
