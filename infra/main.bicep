@description('Environment name (dev, prod, etc.)')
param environmentName string = 'dev'

@description('Project name')
param projectName string = 'FakeAlwaysOn'

@description('Azure region for resources')
param location string = resourceGroup().location

@description('JSON array of endpoints to health check')
param endpoints array = ['https://example.com/health']

@description('Expected HTTP status code for healthy response')
param expectedStatusCode int = 200

@description('Timer trigger interval (CRON expression for every 5 minutes)')
param timerInterval string = '0 */5 * * * *'

var uniqueId = uniqueString(resourceGroup().id)
var functionAppName = '${replace(projectName, '-', '')}${uniqueId}'
var storageAccountName = substring(concat(replace(toLower(projectName), '-', ''), uniqueId), 0, 24)
var appInsightsName = '${projectName}-${environmentName}-ai'
var logWorkspaceName = '${projectName}-${environmentName}-law'
var appServicePlanName = '${projectName}-${environmentName}-asp'

// Create Log Analytics Workspace
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Create Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logWorkspace.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// Create App Service Plan (Consumption)
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

// Create Function App
resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
        {
          name: 'ENDPOINTS'
          value: string(endpoints)
        }
        {
          name: 'EXPECTED_STATUS_CODE'
          value: string(expectedStatusCode)
        }
        {
          name: 'TIMER_INTERVAL'
          value: timerInterval
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      http20Enabled: true
    }
    httpsOnly: true
  }
}

@description('Storage account connection string for local development')
output storageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

@description('Function App name')
output functionAppName string = functionApp.name

@description('Function App ID')
output functionAppId string = functionApp.id

@description('Application Insights Instrumentation Key')
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

@description('Application Insights Connection String')
output appInsightsConnectionString string = appInsights.properties.ConnectionString
