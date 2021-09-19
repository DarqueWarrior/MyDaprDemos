targetScope = 'subscription'

param tenantId string
param objectId string
param location string = 'eastus'
param rgName string = 'dapr_secrets_demo'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module secrets './secrets.bicep' = {
  name: 'secrets'
  scope: resourceGroup(rg.name)
  params: {
    tenantId: tenantId
    objectId: objectId
  }
}

output keyvaultName string = secrets.outputs.keyvaultName
