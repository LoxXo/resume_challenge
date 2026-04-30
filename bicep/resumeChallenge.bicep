targetScope='subscription'

param resourceGroupName string
param resourceGroupLocation string

resource newRG 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

module cdbacc 'cosmosDBAccount.bicep' = {
  scope: newRG
  name: 'cosmosDBAccount'
}

module swa 'staticWebApp.bicep' = {
  scope: newRG
  name: 'staticWebApp'
}

module fapp 'functionApp.bicep' = {
  scope: newRG
  name: 'functionApp-v2'
  params: {
    staticWebAppHostname: swa.outputs.endpoint
  }
}

