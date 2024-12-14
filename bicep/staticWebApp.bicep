targetScope = 'resourceGroup'

param staticWebAppName string = 'web-${uniqueString(resourceGroup().id)}'
param staticWebAppLocation string = '${resourceGroup().location}2'
param customDomainName string = 'jwajda.com'

module swa 'br/public:avm/res/web/static-site:0.6.1' = {
  name: 'staticWeb'
  params: {
    name: staticWebAppName
    location: staticWebAppLocation
    sku: 'Free'
  }
}

output name string = swa.name
output hostname string = swa.outputs.defaultHostname

resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' existing = {
  name: staticWebAppName

  resource prodCustomDomain 'customDomains' = {
    name: customDomainName
  }
}
