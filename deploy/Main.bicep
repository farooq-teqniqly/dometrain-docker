targetScope = 'subscription'

param uniquePrefix string
param sshKey string

var location = deployment().location
var resourceGroupName = '${uniquePrefix}-rg'
var acrName = '${replace(uniquePrefix, '-', '')}acr'
var aksName = '${replace(uniquePrefix, '-', '')}aks'

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

module aksDeploy 'Aks.bicep' = {
  name: 'aksDeploy'
  scope: rg
  params: {
    clusterName: aksName
    location: location
    dnsPrefix: '${uniquePrefix}-dns'
    linuxAdminUsername: 'azureuser'
    sshPublicKey: sshKey
  }
}

output deploymentOutputs object = {
  resourceGroupName: resourceGroupName
  acrDeployment: {
    name: acrName
    loginServer: acrDeploy.outputs.loginServer
  }
  aksDeployment: {
    controlPlaneFQDN: aksDeploy.outputs.controlPlaneFQDN
    clusterName: aksDeploy.outputs.clusterName
  }
}
