using 'main.bicep'
param environmentName = 'dev'
param projectName = 'FakeAlwaysOn'
param location = 'westeurope'
param endpoints = [
  'https://example.com/health'
  'https://your-app.azurewebsites.net/health'
]
param expectedStatusCode = 200
param timerInterval = '0 */5 * * * *'
