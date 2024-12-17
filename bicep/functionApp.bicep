targetScope = 'resourceGroup'

param functionName string = 'func-${uniqueString(resourceGroup().id)}'
param functionLocation string = '${resourceGroup().location}2'

resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: functionName
  location: functionLocation
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionName
  location: functionLocation
  kind: 'functionapp'
}
