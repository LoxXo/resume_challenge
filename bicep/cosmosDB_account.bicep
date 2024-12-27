targetScope = 'resourceGroup'

param cdbAccountName string = 'cosmos-${uniqueString(resourceGroup().id)}'
param cdbAccountLocation string = '${resourceGroup().location}2'
param cdbDatabaseName string
param cdbContainerName string

resource cdbacc 'Microsoft.DocumentDB/databaseAccounts@2024-08-15' = {
  name: cdbAccountName
  location: cdbAccountLocation
  properties: {
    enableFreeTier: true
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    capacity: {
      totalThroughputLimit: 1000
    }
    locations: [{
      locationName: cdbAccountLocation
    }]
  }
}

resource cdbdatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-08-15' = {
  parent: cdbacc
  name: cdbDatabaseName
  properties: {
    resource: {
      id: cdbDatabaseName
    }
  options: {
    throughput: 1000
  }
}
}

resource cdbcontainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-08-15' = {
  parent: cdbdatabase
  name: cdbContainerName
  properties: {
    resource: {
      id: cdbContainerName
    }
  }
}
