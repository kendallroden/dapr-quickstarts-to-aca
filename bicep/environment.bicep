param environmentName string
param logAnalyticsWorkspaceName string = 'logs-${environmentName}'
param location string = resourceGroup().location
param logAnalyticsLocation string = 'canadacentral'

resource managedEnvironment 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: environmentName
  location: location
  properties: {
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference('Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}', '2020-08-01').customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    type: 'managed'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: logAnalyticsLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {}
  }
  dependsOn: []
}

output location string = location
output environmentId string = managedEnvironment.id
