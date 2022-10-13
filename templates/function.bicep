@description('The location of the app service plan.')
param _appServiceLocation string = resourceGroup().location

@description('The name of the app service plan resource.')
param _appServicePlanName string

@description('The name of the application function app resource.')
param _functionAppApplicationName string

@description('The name of the storage account resource.')
param _storageAccountName string

@description('The name of the application insights resource.')
param _applicationInsightsName string

resource functionAppApplicationStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: toLower(_storageAccountName)
}

resource functionAppApplicationStorageAccountFileService 'Microsoft.Storage/storageAccounts/fileServices@2022-05-01' existing = {
  name: 'default'
  parent: functionAppApplicationStorageAccount
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: toLower(_applicationInsightsName)
}


resource functionAppApplicationStorageAccountFileServiceShareProduction 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-05-01' = {
  name: toLower('${_functionAppApplicationName}-c85b1af5')
  parent: functionAppApplicationStorageAccountFileService
  properties: {
    accessTier: 'TransactionOptimized'
    enabledProtocols: 'SMB'
    shareQuota: 5120
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: _appServicePlanName
  location: _appServiceLocation
  sku: {
    name: 'EP2'
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: 2
    perSiteScaling: true
  }
}

resource functionAppApplication 'Microsoft.Web/sites@2022-03-01' = {
  name: _functionAppApplicationName
  location: _appServiceLocation
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    clientAffinityEnabled: false
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }         
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionAppApplicationStorageAccount.name};AccountKey=${functionAppApplicationStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionAppApplicationStorageAccount.name};AccountKey=${functionAppApplicationStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionAppApplicationStorageAccountFileServiceShareProduction.name
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      use32BitWorkerProcess: false
    }
  }
}
