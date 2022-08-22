targetScope = 'subscription'

param location string = 'eastus'
param k8sversion string = '1.21.2'
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
    k8sversion: k8sversion
  }
}

output aksName string = devops.outputs.clusterName
output storageAccountKey string = devops.outputs.storageAccountKey
output storageAccountName string = devops.outputs.storageAccountName
output serviceBusEndpoint string = devops.outputs.serviceBusEndpoint
output cognitiveServiceKey string = devops.outputs.cognitiveServiceKey
output cognitiveServiceEndpoint string = devops.outputs.cognitiveServiceEndpoint
