targetScope = 'resourceGroup'

@description('Language runtime used by the function app.')
@allowed(['dotnet-isolated','python','java', 'node', 'powerShell'])
param functionAppRuntime string = 'python'

@description('Target language version used by the function app.')
@allowed(['3.10','3.11', '7.4', '8.0', '9.0', '10', '11', '17', '20'])
param functionAppRuntimeVersion string = '3.11'

@description('The maximum scale-out instance count limit for the app.')
@minValue(40)
@maxValue(1000)
param maximumInstanceCount int = 40

@description('The memory size of instances used by the app.')
@allowed([2048,4096])
param instanceMemoryMB int = 2048

param functionName string = 'func-http-trigger-resume'
param functionLocation string = resourceGroup().location
// param storageAccountType string = 'Standard_LRS'
param privateDnsName string = 'jwajda.com'
param staticWebAppHostname string = 'web-resume-00'

// Generates a unique container name for deployments.
var deploymentStorageContainerName = 'app-package-${take(functionName, 32)}-${(uniqueString(resourceGroup().id))}'

var cdbAccountName = 'cosmos-resume-${uniqueString(resourceGroup().id)}'
var storageAccountName = 'strgresume${uniqueString(resourceGroup().id)}'
//var functionAppName = functionName

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2024-12-01-preview' existing = {
  name: cdbAccountName
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.25.0' = {
  name: 'storageaccount'
  params: {
    name: storageAccountName
    allowBlobPublicAccess: false
    // allowSharedKeyAccess: false // Disable local authentication methods which we use
    dnsEndpointType: 'Standard'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    blobServices: {
      containers: [{name: deploymentStorageContainerName}]
    }
    tableServices:{}
    queueServices: {}
    minimumTlsVersion: 'TLS1_2'  // Enforcing TLS 1.2 for better security
    location: functionLocation
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan 'br/public:avm/res/web/serverfarm:0.1.1' = {
  name: 'appserviceplan'
  params: {
    name: functionName
    sku: {
      name: 'FC1'
      tier: 'FlexConsumption'
    }
    reserved: true
    location: functionLocation
  }
}

@description('Azure Functions Flex Consumption')
module functionApp 'br/public:avm/res/web/site:0.16.0' = {
  name: 'functionapp'
  params: {
    kind: 'functionapp,linux'
    name: functionName
    location: functionLocation
    serverFarmResourceId: appServicePlan.outputs.resourceId
    httpsOnly: true
    managedIdentities: {
      systemAssigned: true
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storageAccount.outputs.primaryBlobEndpoint}${deploymentStorageContainerName}'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: maximumInstanceCount
        instanceMemoryMB: instanceMemoryMB
      }
      runtime: { 
        name: functionAppRuntime
        version: functionAppRuntimeVersion
      }
    }
    siteConfig: {
      // alwaysOn: false
      cors: {
        allowedOrigins: ['https://${privateDnsName}','https://${staticWebAppHostname}']
        supportCredentials: false
      }
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.outputs.primaryAccessKey};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
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
    }
    configs: [{
      name: 'appsettings'
      properties:{
        // Only include required credential settings unconditionally
        AzureWebJobsStorage__credential: 'managedidentity'
        AzureWebJobsStorage__blobServiceUri: 'https://${storageAccount.outputs.name}.blob.${environment().suffixes.storage}'
        AzureWebJobsStorage__queueServiceUri: 'https://${storageAccount.outputs.name}.queue.${environment().suffixes.storage}'
        AzureWebJobsStorage__tableServiceUri: 'https://${storageAccount.outputs.name}.table.${environment().suffixes.storage}'
      }
    }]
  }
}
