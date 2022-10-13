@description('The location of the app insights resource.')
param _applicationInsightsLocation string = resourceGroup().location

@description('The name of the app insights resource.')
param _applicationInsightsName string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: _applicationInsightsName
  location: _applicationInsightsLocation
  kind: 'web'
  properties: {
    Application_Type:'web'
    RetentionInDays: 30
  }
}
