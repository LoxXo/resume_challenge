targetScope='subscription'

param resourceGroupName string
param resourceGroupLocation string

/*param staticWebAppName string = 
param staticWebAppLocation string
param cdbAccountLocation string
param cdbAccountName string
param functionName string
param functionLocation string*/

resource newRG 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

module swa 'staticWebApp.bicep' = {
  scope: newRG
  name: 'staticWebApp'
}

module cdbacc 'cosmosDB_account.bicep' = {
  scope: newRG
  name: 'cosmosDBAccount'
}

/*
module fapp 'functionApp.bicep' = {
  scope: newRG
  name: 'functionApp'
}
*/
