var dbName = 'StateStore'
var containerName = 'StateStoreValues'

resource cdb 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  name: 'cdb${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: resourceGroup().location
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
