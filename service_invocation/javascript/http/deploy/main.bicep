param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'
param minReplicas int = 0
param checkoutImage string = 'nginx'
param orderProcessorImage string = 'nginx'
param containerRegistry string
param containerRegistryUsername string

@secure()
param containerRegistryPassword string

// Container App Environment
module environment '../../../../bicep/environment.bicep' = {
  name: 'container-app-environment'
  params: {
    environmentName: environmentName
    location: location
    logAnalyticsLocation: 'canadacentral'
  }
}

// Checkout Service
module CheckoutService '../../../../bicep/container-http.bicep' = {
  name: 'checkout'
  dependsOn: [
    OrderProcessorService
  ]
  params: {
    location: location
    containerAppName: 'checkout'
    environmentId: environment.outputs.environmentId
    containerImage: checkoutImage
    containerPort: 3000
    isExternalIngress: false
    minReplicas: minReplicas
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    containerRegistryPassword: containerRegistryPassword
    secrets: [
      {
        name: 'docker-password'
        value: containerRegistryPassword
      }
    ]
  }
}


// Order Processor Service
module OrderProcessorService '../../../../bicep/container-http.bicep' = {
  name: 'order-processor'
  params: {
    location: location
    containerAppName: 'order-processor'
    environmentId: environment.outputs.environmentId
    containerImage: orderProcessorImage
    containerPort: 5001
    isExternalIngress: false
    minReplicas: minReplicas
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    containerRegistryPassword: containerRegistryPassword
    secrets: [
      {
        name: 'docker-password'
        value: containerRegistryPassword
      }
    ]
  }
}
