param location string
param name string
param sku string
param adminUserEnabled bool

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: name
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': name
  }
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

output loginServer string = acr.properties.loginServer
