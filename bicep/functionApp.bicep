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
    // allowSharedKeyAccess: false // Disable local authentication methods as per policy
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.outputs.primaryAccessKey}'
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

// resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
//   name: storageAccountName
//   location: functionLocation
//   sku: {
//     name: storageAccountType
//   }
//   kind: 'StorageV2'
//   properties: {
//     supportsHttpsTrafficOnly: true
//     defaultToOAuthAuthentication: true
//     minimumTlsVersion: 'TLS1_2'
//   }
// }

// @description('linux is required to run python, functionapp is consumption plan, reserved: true is needed to select Linux')
// resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
//   name: functionName
//   location: functionLocation
//   kind: 'functionapp,linux'
//   sku: {
  //     tier: 'FlexConsumption'
  //     name: 'FC1'
  //   }
  //   properties: {
    //     reserved: true
    //   }
// }

// @description('appSettings are Environment Variables')
// resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
//   name: functionName
//   location: functionLocation
//   kind: 'functionapp,linux'
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     serverFarmId: hostingPlan.id
//     siteConfig: {
//       appSettings: [
//         {
//           name: 'AzureWebJobsStorage'
//           value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
//         }
//         // {
//         //   name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
//         //   value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
//         // }
//         // {
//         //   name: 'WEBSITE_CONTENTSHARE'
//         //   value: toLower(functionAppName)
//         // }
//         {
//           name: 'FUNCTIONS_EXTENSION_VERSION'
//           value: '~4'
//         }
//         // {
//         //   name: 'FUNCTIONS_WORKER_RUNTIME'
//         //   value: 'python'
//         // }
//         {
//           name: 'CosmosDbConnectionSetting'
//           value: databaseAccount.listConnectionStrings().connectionStrings[0].connectionString
//         }
//         {
//           name: 'COSMOS_CONTAINER'
//           value: 'Container1'
//         }
//         {
//           name: 'COSMOS_DATABASE'
//           value: 'ResumeLive'
//         }
//         {
//           name: 'COSMOS_CONTAINER_COUNTER'
//           value: 'visitors'
//         }
//       ]
//       ftpsState: 'FtpsOnly'
//       minTlsVersion: '1.2'
//     }
//     functionAppConfig: {
//       deployment: {
//         storage: {
//           type: 'blobContainer'
//           value: 'https://${storageAccountName}.blob.${environment().suffixes.storage}/${deploymentStorageContainerName}'
//           // value: '${storageAccount.properties.primaryEndpoints.blob}${deploymentStorageContainerName}'
//           authentication: {
//             type: 'StorageAccountConnectionString'
//             storageAccountConnectionStringName: 'AzureWebJobsStorage'
//           }
//         }
//       }
//       scaleAndConcurrency: {
//         maximumInstanceCount: maximumInstanceCount
//         instanceMemoryMB: instanceMemoryMB
//       }
//       runtime: { 
//         name: functionAppRuntime
//         version: functionAppRuntimeVersion
//       }
//     }
//     httpsOnly: true
//   }
// }

// @description('Seems like CORS needs to be added after creating FunctionApp')
// resource functionAppSiteConfig 'Microsoft.Web/sites/config@2022-03-01' = {
//   parent: function
//   name: 'web'
//   properties: {
//     cors: {
//       allowedOrigins: ['https://${privateDnsName}','https://${staticWebAppHostname}']
//       supportCredentials: false
//     }
//   }
// }


