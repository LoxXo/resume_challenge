targetScope = 'resourceGroup'

param staticWebAppName string = 'web-${uniqueString(resourceGroup().id)}'
param staticWebAppLocation string = '${resourceGroup().location}2'

module swa 'br/public:avm/res/web/static-site:0.6.1' = {
  name: 'staticWeb'
  params: {
    name: staticWebAppName
    location: staticWebAppLocation
    sku: 'Free'
  }
}
