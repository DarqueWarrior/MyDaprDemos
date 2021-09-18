param location string = 'eastus2'

var sbApiVersion = '2017-04-01'
var sbName = 'sb${uniqueString(resourceGroup().id)}'
var defaultSASKeyName = 'RootManageSharedAccessKey'
var authRuleResourceId = resourceId('Microsoft.ServiceBus/namespaces/authorizationRules', sbName, defaultSASKeyName)

resource sb 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: sbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

output serviceBusEndpoint string = listkeys(authRuleResourceId, sbApiVersion).primaryConnectionString
