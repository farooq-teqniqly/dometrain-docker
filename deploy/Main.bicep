targetScope = 'subscription'

param uniquePrefix string

var location = deployment().location
var resourceGroupName = '${uniquePrefix}-rg'
var acrName = '${replace(uniquePrefix, '-', '')}acr'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module acrDeploy 'Acr.bicep' = {
  name: 'acrDeploy'
  scope: rg
  params: {
    location: location
    name: acrName
    sku: 'Basic'
    adminUserEnabled: true
  }
}

output deploymentOutputs object = {
  resourceGroupName: resourceGroupName
  acrDeployment: {
    name: acrName
    loginServer: acrDeploy.outputs.loginServer
  }
}
