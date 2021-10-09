targetScope = 'subscription'

param location string = 'eastus'
param rgName string = 'dapr_devops_demo'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module devops './devops.bicep' = {
  name: 'devops'
  scope: resourceGroup(rg.name)
  params: {
  }
}

output cognitiveServiceKey string = devops.outputs.cognitiveServiceKey
output cognitiveServiceEndpoint string = devops.outputs.cognitiveServiceEndpoint
