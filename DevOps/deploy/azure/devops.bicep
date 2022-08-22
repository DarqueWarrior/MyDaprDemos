param location string
param k8sversion string

var csName = 'cs${uniqueString(resourceGroup().id)}'
var aksName = 'aks${uniqueString(resourceGroup().id)}'
var dnsPrefix = '${aksName}-dns'

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

resource aks 'Microsoft.ContainerService/managedClusters@2020-09-01' = {
  name: aksName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  properties: {
    kubernetesVersion: k8sversion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 128
        count: 3
        vmSize: 'Standard_A2_v2'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: [
          '1'
        ]
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'kubenet'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: true
      }
      azurePolicy: {
        enabled: false
      }
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output clusterName string = aksName
output storageAccountName string = stg.name
#disable-next-line outputs-should-not-contain-secrets
output cognitiveServiceKey string = cs.listkeys().key1
#disable-next-line outputs-should-not-contain-secrets
output storageAccountKey string = stg.listKeys().keys[0].value
output cognitiveServiceEndpoint string = reference(csName).endpoint
#disable-next-line outputs-should-not-contain-secrets
output serviceBusEndpoint string = sbAuthRule.listkeys().primaryConnectionString
