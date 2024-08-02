targetScope = 'subscription'

param uniquePrefix string
param resourceGroupName string

var location = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module acrDeploy 'Acr.bicep' = {
  name: 'acrDeploy'
  scope: rg
  params: {
    location: location
    name: '${uniquePrefix}-acr'
    sku: 'Basic'
    adminUserEnabled: true
  }
}

output deploymentOutputs object = {
  resourceGroupName: resourceGroupName
  acrDeployment: {
    loginServer: acrDeploy.outputs.loginServer
  }
}
