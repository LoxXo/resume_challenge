targetScope = 'resourceGroup'

param cdbAccountName string = 'cosmos-resume-${uniqueString(resourceGroup().id)}'
param cdbAccountLocation string = resourceGroup().location
@description('static database same as in the functionApp.bicep')
param databaseName string = 'ResumeLive'
@description('static container name same as in the functionApp.bicep')
param containerName string = 'Container1'
param cdbExists bool = false

resource resManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: 'rg-resume-00'
  location: 'northeurope'
}

@description('Run PowerShell script to check if the Cosmos DB account already exists')
resource checkCdbAccount 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'checkCdbAccount'
  location: cdbAccountLocation
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resManagedIdentity.id}' : {}
    }
  }
  properties: {
    azPowerShellVersion: '9.4'
    scriptContent: '''
      $cdbAccountName = '${cdbAccountName}'
      $resourceGroupName = '${resourceGroup().name}'
      $cdbAccount = Get-AzCosmosDBAccount -ResourceGroupName $resourceGroupName -Name $cdbAccountName
      if ($cdbAccount) {
        Write-Output "Cosmos DB account $cdbAccountName already exists."
        $ScriptOutputs = $true
      } else {
        Write-Output "Cosmos DB account $cdbAccountName does not exist."
        $ScriptOutputs = $false
      }
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['resourceExists'] = $ScriptOutputs
    '''
    arguments: ''
    timeout: 'PT30M'
    retentionInterval: 'P1D'
    cleanupPreference: 'Always'
  }
}
output cdbExists bool = checkCdbAccount.properties.outputs.resourceExists

@description('Only one account can be created on Free Tier and any atempt to create more will return an error')
resource cdbaccnew 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = if (cdbExists == false) {
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
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-11-15' = if (cdbExists == false) {
  parent: cdbaccnew
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

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-11-15' = if (cdbExists == false) {
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
