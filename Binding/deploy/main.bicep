targetScope = 'subscription'

param location string = 'eastus'
param rgName string = 'dapr_binding_demo'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module binding './binding.bicep' = {
  name: 'binding'
  scope: resourceGroup(rg.name)
}

output storageAccountKey string = binding.outputs.storageAccountKey
output storageAccountName string = binding.outputs.storageAccountName
