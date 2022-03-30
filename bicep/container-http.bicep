param containerAppName string
param location string
param environmentId string
param containerRegistryUsername string
param containerImage string
param containerPort int
param isExternalIngress bool 
param enableIngress bool 
param containerRegistry string
param env array = []
param minReplicas int
param secrets array = []

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      secrets: secrets
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: 'reg-password'
        }
      ]
      ingress: (enableIngress == true) ? null : {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
      }
      dapr: {
        enabled: true
        appPort: containerPort
        appProtocol: 'http'
        appId: containerAppName
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
        }
      ]
      scale: {
        minReplicas: minReplicas
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
