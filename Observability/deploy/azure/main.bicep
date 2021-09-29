targetScope = 'subscription'

param location string = 'eastus'
param rgName string = 'dapr_observability_demo'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module observability './observability.bicep' = {
  name: 'observability'
  scope: resourceGroup(rg.name)
}

output instrumentationKey string = observability.outputs.instrumentationKey
