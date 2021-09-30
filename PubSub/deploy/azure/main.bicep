targetScope = 'subscription'

param ipAddress string
param adminPassword string
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
    ipAddress: ipAddress
    adminPassword: adminPassword
  }
}

output databaseName string = pubsub.outputs.databaseName
output storageAccountKey string = pubsub.outputs.storageAccountKey
output eventHubsEndpoint string = pubsub.outputs.eventHubsEndpoint
output serviceBusEndpoint string = pubsub.outputs.serviceBusEndpoint
output administratorLogin string = pubsub.outputs.administratorLogin
output storageAccountName string = pubsub.outputs.storageAccountName
output fullyQualifiedDomainName string = pubsub.outputs.fullyQualifiedDomainName
