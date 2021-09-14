param uniqueValue string
param location string = 'eastus2'

var cdbName = 'cdb${uniqueValue}'

resource cdb 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  name: cdbName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}

output cosmosDbKey string = cdb.listKeys().primaryMasterKey
output cosmosDbEndpoint string = cdb.properties.documentEndpoint
