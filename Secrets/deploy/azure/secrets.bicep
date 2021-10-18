param tenantId string
param objectId string

var kvName = 'kv${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvName
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: false
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
            'set'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${kvName}/dapr-secret'
  properties: {
    value: 'Dapr_Secret_From_Azure_KeyVault'
  }
  dependsOn: [
    keyVault
  ]
}

output keyvaultName string = kvName
