param ipAddress string
param adminPassword string

resource sb 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: 'sb${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

resource sbAuthRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2017-04-01' existing = {
  parent: sb
  name: 'RootManageSharedAccessKey'
}

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: 'sql${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
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
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

output databaseName string = sqlServerDatabase.name
output administratorLogin string = sqlServer.properties.administratorLogin
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

output serviceBusEndpoint string = sbAuthRule.listkeys().primaryConnectionString
