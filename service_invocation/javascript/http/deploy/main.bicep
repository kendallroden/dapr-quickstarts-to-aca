param location string = resourceGroup().location
param uniqueSeed string = '${subscription().subscriptionId}-${resourceGroup().name}'
param uniqueSuffix string = 'daprcapps-${uniqueString(uniqueSeed)}'
param containerAppsEnvName string = 'cae-${uniqueSuffix}'
param logAnalyticsWorkspaceName string = 'log-${uniqueSuffix}'
param appInsightsName string = 'ai-${uniqueSuffix}'
param minReplicas int = 1
param checkoutImage string
param orderProcessorImage string
param containerRegistry string
param containerRegistryUsername string

@secure()
param containerRegistryPassword string

// Container Apps Environment
module containerAppsEnvModule '../../../../bicep/environment.bicep' = {
  name:'${deployment().name}--containerAppsEnv'
  params: {
    containerAppsEnvName: containerAppsEnvName
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsName: appInsightsName 
  }
}

// Checkout Service
module checkoutServiceModule '../../../../bicep/container-http.bicep' = {
  name: '${deployment().name}--checkout-service'
   dependsOn: [
    orderProcessorServiceModule
    containerAppsEnvModule
  ]
  params: {
    location: location
    environmentId: containerAppsEnvModule.outputs.environmentId
    containerAppName: 'checkout'
    containerPort: 3000
    enableIngress: false
    isExternalIngress: false
    minReplicas: minReplicas
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    containerImage: checkoutImage
    secrets: [
      {
        name: 'reg-password'
        value: containerRegistryPassword
      }
    ]
  }
  dependsOn: [
    OrderProcessorService
  ]
}


// Order Processor Service
module orderProcessorServiceModule '../../../../bicep/container-http.bicep' = {
  name: '${deployment().name}--order-processor-service'
   dependsOn: [
    containerAppsEnvModule
  ]
  params: {
    location: location
    environmentId: containerAppsEnvModule.outputs.environmentId
    containerAppName: 'order-processor'
    containerImage: orderProcessorImage
    containerPort: 5001
    enableIngress: true
    isExternalIngress: false
    minReplicas: minReplicas
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    secrets: [
      {
        name: 'reg-password'
        value: containerRegistryPassword
      }
    ]
  }
}
