param location string = 'eastus2'

var dbName = 'StateStore'
var containerName = 'StateStoreValues'
var cdbName = 'cdb${uniqueString(resourceGroup().id)}'

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

resource db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
  name: dbName
  parent: cdb
  properties: {
    resource: {
      id: dbName
    }
  }
}

resource dbContiner 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-06-15' = {
  name: containerName
  parent: db
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
      }
    }
  }
}

output cosmosDbKey string = cdb.listKeys().primaryMasterKey
output cosmosDbEndpoint string = cdb.properties.documentEndpoint
