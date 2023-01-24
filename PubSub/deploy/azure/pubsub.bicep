param location string
param ipAddress string
param topicName string
param serviceName string
@secure()
param adminPassword string

// PubSub backed by Azure Service Bus
resource sb 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: 'sb${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

resource sbAuthRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-06-01-preview' existing = {
  parent: sb
  name: 'RootManageSharedAccessKey'
}

// PubSub backed by Azure Event Hubs
resource ehNamespace 'Microsoft.EventHub/namespaces@2021-06-01-preview' = {
  name: 'eh${uniqueString(resourceGroup().id)}'
  location: location
}

resource eh 'Microsoft.EventHub/namespaces/eventhubs@2021-06-01-preview' = {
  parent: ehNamespace
  name: topicName
  properties: {}
}

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-06-01-preview' = {
  parent: eh
  name: serviceName
}

resource neworderAuth 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-06-01-preview' = {
  parent: eh
  name: 'dapr'
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
  }
}

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: toLower('stg${uniqueString(resourceGroup().id)}') // must be globally unique
  location: location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}

// State Store using Azure SQL
resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: 'sql${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    administratorLogin: 'dapr'
    administratorLoginPassword: adminPassword
  }
}

resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallRules@2020-11-01-preview' = {
  parent: sqlServer
  name: 'codespaces rule'
  properties: {
    startIpAddress: ipAddress
    endIpAddress: ipAddress
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: 'dapr'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

output storageAccountName string = stg.name

output databaseName string = sqlServerDatabase.name
output administratorLogin string = sqlServer.properties.administratorLogin
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

output serviceBusNamespace string = sb.name
output serviceBusAuthRule string = sbAuthRule.name

output eventHubName string = eh.name
output eventHubAuthRule string = neworderAuth.name
output eventHubsNamespace string = ehNamespace.name
