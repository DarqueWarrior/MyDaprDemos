targetScope = 'subscription'

param location string = 'eastus'
param rgName string = 'dapr_pubsub_demo'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module pubsub './pubsub.bicep' = {
  name: 'pubsub'
  scope: resourceGroup(rg.name)
  params: {
    location: location
  }
}

output storageAccountKey string = pubsub.outputs.storageAccountKey
output storageAccountName string = pubsub.outputs.storageAccountName
output serviceBusEndpoint string = pubsub.outputs.serviceBusEndpoint
