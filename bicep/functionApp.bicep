  targetScope = 'resourceGroup'

param functionName string = 'func-http-trigger-resume'
param functionLocation string = resourceGroup().location
param storageAccountType string = 'Standard_LRS'
param staticWebAppHostname string
param cdbAccountName string = 'cosmos-resume-${uniqueString(resourceGroup().id)}'

var storageAccountName = 'strgresume${uniqueString(resourceGroup().id)}'
var functionAppName = functionName

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
  name: cdbAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: functionLocation
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: functionName
  location: functionLocation
  sku: {
    name: 'Y1'
  }
  kind: 'functionapp,linux'
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionName
  location: functionLocation
  // linux is required for python, functionapp is consumption plan
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'CosmosDbConnectionSetting'
          value: databaseAccount.listConnectionStrings().connectionStrings[0].connectionString
        }
        {
          name: 'COSMOS_CONTAINER'
          value: 'Container1'
        }
        {
          name: 'COSMOS_DATABASE'
          value: 'ResumeLive'
        }
        {
          name: 'COSMOS_CONTAINER_COUNTER'
          value: 'visitors'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      linuxFxVersion: 'Python|3.11'
    }
    httpsOnly: true
  }
}

resource functionAppSiteConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionApp
  name: 'web'
  properties: {
    cors: {
      allowedOrigins: ['https://jwajda.com','https://${staticWebAppHostname}']
      supportCredentials: false
    }
  }
}
