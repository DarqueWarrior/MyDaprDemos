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

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: toLower('stg${uniqueString(resourceGroup().id)}') // must be globally unique
  location: resourceGroup().location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}

output storageAccountName string = stg.name
output storageAccountKey string = stg.listKeys().keys[0].value
output serviceBusEndpoint string = sbAuthRule.listkeys().primaryConnectionString
