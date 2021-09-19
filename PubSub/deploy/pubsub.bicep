var sbApiVersion = '2017-04-01'
var sbName = 'sb${uniqueString(resourceGroup().id)}'
var defaultSASKeyName = 'RootManageSharedAccessKey'
var authRuleResourceId = resourceId('Microsoft.ServiceBus/namespaces/authorizationRules', sbName, defaultSASKeyName)

var stgApiVersion = '2019-06-01'
var stgName = toLower('stg${uniqueString(resourceGroup().id)}')
var storageAccountId = resourceId('Microsoft.Storage/storageAccounts', stgName)

resource sb 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: sbName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}
}

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: stgName // must be globally unique
  location: resourceGroup().location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}

output storageAccountName string = stgName
output storageAccountKey string = listKeys(storageAccountId, stgApiVersion).keys[0].value
output serviceBusEndpoint string = listkeys(authRuleResourceId, sbApiVersion).primaryConnectionString
