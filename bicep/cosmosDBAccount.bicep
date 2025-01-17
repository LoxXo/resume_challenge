targetScope = 'resourceGroup'

param cdbAccountName string = 'cosmos-resume-${uniqueString(resourceGroup().id)}'
param cdbAccountLocation string = resourceGroup().location
@description('static database same as in the functionApp.bicep')
param databaseName string = 'ResumeLive'
@description('static container name same as in the functionApp.bicep')
param containerName string = 'Container1'

@description('Only one account can be created on Free Tier and any atempt to create more will return an error')
resource cdbacc 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
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
@description('Need to be deployed with container before running API. Python azure.functions in theory allows to dynamically create databases and containers, but in practice it does not work')
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-11-15' = {
  parent: cdbacc
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: 1000
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-11-15' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
    }
  }
}
