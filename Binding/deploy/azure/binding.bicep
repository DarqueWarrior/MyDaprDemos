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
