param location string

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: 'ws${uniqueString(resourceGroup().id)}'
  location: location
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'appi${uniqueString(resourceGroup().id)}'
  kind: 'web'
  location: location
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
    publicNetworkAccessForQuery: 'Enabled'
    publicNetworkAccessForIngestion: 'Enabled'
  }
}

output instrumentationKey string = appInsights.properties.InstrumentationKey
