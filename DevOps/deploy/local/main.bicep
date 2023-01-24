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
    location: location
  }
}

output storageAccountName string = devops.outputs.storageAccountName

output serviceBusAuthRule string = devops.outputs.serviceBusAuthRule
output serviceBusNamespace string = devops.outputs.serviceBusNamespace

output cognitiveServiceName string = devops.outputs.cognitiveServiceName
output cognitiveServiceEndpoint string = devops.outputs.cognitiveServiceEndpoint

output instrumentationKey string = devops.outputs.instrumentationKey
