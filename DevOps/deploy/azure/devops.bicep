var csName = 'cs${uniqueString(resourceGroup().id)}'

resource cs 'Microsoft.CognitiveServices/accounts@2017-04-18' = {
  name: csName
  kind: 'CognitiveServices'
  location: resourceGroup().location
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: csName
  }
}

output cognitiveServiceKey string = cs.listkeys().key1
output cognitiveServiceEndpoint string = reference(csName).endpoint
