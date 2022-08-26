param location string

var csName = 'cs${uniqueString(resourceGroup().id)}'

resource cs 'Microsoft.CognitiveServices/accounts@2017-04-18' = {
  name: csName
  kind: 'CognitiveServices'
  location: location
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: csName
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

output storageAccountName string = stg.name

output cognitiveServiceName string = cs.name
output cognitiveServiceEndpoint string = reference(cs.name).endpoint

output serviceBusNamespace string = sb.name
output serviceBusAuthRule string = sbAuthRule.name
