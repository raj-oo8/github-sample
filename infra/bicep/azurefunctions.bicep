param hostingPlanName string
param hostingPlanLocation string
param functionAppName string
param functionAppLocation string
param staticSiteEndpoint string
param storageAccountName string
param signalRName string

resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: hostingPlanName
  location: hostingPlanLocation
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource signalR 'Microsoft.SignalRService/signalR@2024-10-01-preview' existing = {
  name: signalRName
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: functionAppLocation
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.listKeys().keys[0].value      
        }
        {
          name: 'AzureSignalRConnectionString'
          value: signalR.listKeys().primaryConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_INPROC_NET8_ENABLED'
          value: '1'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
      cors: {
        allowedOrigins: [
          staticSiteEndpoint
        ]
      }
    }
  }
}

output functionAppEndpoint string = functionApp.properties.defaultHostName
output functionAppName string = functionApp.name
