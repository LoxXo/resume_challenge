targetScope = 'resourceGroup'

param staticWebAppName string = 'web-resume-${uniqueString(resourceGroup().id)}'
@allowed(
  ['westus2'
  'centralus'
  'eastus2'
  'westeurope'
  'eastasia']
)
param staticWebAppLocation string = 'westeurope'

module swa 'br/public:avm/res/web/static-site:0.6.1' = {
  name: 'staticWeb'
  params: {
    name: staticWebAppName
    location: staticWebAppLocation
    sku: 'Free'
  }
}
output endpoint string = swa.outputs.defaultHostname
