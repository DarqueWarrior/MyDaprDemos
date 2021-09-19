var stgApiVersion = '2019-06-01'
var stgName = toLower('stg${uniqueString(resourceGroup().id)}')
var storageAccountId = resourceId('Microsoft.Storage/storageAccounts', stgName)

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
