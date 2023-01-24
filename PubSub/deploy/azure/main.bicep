targetScope = 'subscription'

param ipAddress string
@secure()
param adminPassword string
param location string = 'eastus'
param serviceName string = 'app1'
param topicName string = 'neworder'
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
    ipAddress: ipAddress
    topicName: topicName
    serviceName: serviceName
    adminPassword: adminPassword
  }
}

output storageAccountName string = pubsub.outputs.storageAccountName

output serviceBusAuthRule string = pubsub.outputs.serviceBusAuthRule
output serviceBusNamespace string = pubsub.outputs.serviceBusNamespace

output eventHubName string = pubsub.outputs.eventHubName
output eventHubAuthRule string = pubsub.outputs.eventHubAuthRule
output eventHubsNamespace string = pubsub.outputs.eventHubsNamespace

output databaseName string = pubsub.outputs.databaseName
output administratorLogin string = pubsub.outputs.administratorLogin
output fullyQualifiedDomainName string = pubsub.outputs.fullyQualifiedDomainName
