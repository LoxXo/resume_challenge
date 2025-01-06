targetScope = 'resourceGroup'

param cdbAccountName string = 'cosmos-resume-${uniqueString(resourceGroup().id)}'
param cdbAccountLocation string = resourceGroup().location

resource cdbacc 'Microsoft.DocumentDB/databaseAccounts@2024-09-01-preview' = {
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
