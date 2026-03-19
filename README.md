# Fake: Always On Feature for free

> About: Azure App Services - AlwaysOn Feature - not available in free plan

I enjoy to run development experiments on cheapest sku, but this means my Web app or Apis always have a slow cold start when I call it after a while. I want them Always On!
This project simulates the feature in a very cheap manner:  Serveless Azure Function in consumption tier makes every x minutes a request to configurable  endpoints. 

## Quick Deploy

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnulllogicone%2FFakeAlwaysOn%2Fmain%2F.azure%2Fazuredeploy.json)


## Acceptance criteria

- The full feature is deployed automatically by IaC CI/CD and all secrets are in keyvault. Costs should be minimal.
- A convenient blue 'Deploay to Azure' button on GitHub readme preview allows easy installation to any tenant.
- It should be easy to configure different target endpoints with frequency and result code handling

## Implementation details

### Lowest cost on Azure
- Consumption plan for Azure Functions
- Configurable array of endpoints to ping
- Configurable interval of ping

### Higher cost for more features
- vnet integration
- workbook dashboard

## Deployment Guide

### Prerequisites
- Azure subscription
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for AZD deployment)
- [Azure Developer CLI (AZD)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) (for local development)

### Option 1: Deploy via Azure Portal (Fastest)
Click the blue "Deploy to Azure" button above and follow the prompts.

### Option 2: Deploy via Azure Developer CLI (AZD)

1. Clone the repository:
```bash
git clone https://github.com/nulllogicone/FakeAlwaysOn.git
cd FakeAlwaysOn
```

2. Initialize AZD:
```bash
azd init --template .
```

3. Deploy to Azure:
```bash
azd up
```

4. During deployment, you'll be prompted for:
   - Azure subscription
   - Azure region
   - Environment name (dev/prod)

### Configuration

The health check function uses environment variables for configuration:

| Variable | Default | Description |
|----------|---------|-------------|
| `ENDPOINTS` | `["https://example.com/health"]` | JSON array of endpoints to health check |
| `EXPECTED_STATUS_CODE` | `200` | Expected HTTP status code for healthy response |
| `TIMER_INTERVAL` | `0 */5 * * * *` | CRON expression for check frequency (every 5 minutes) |

#### Updating Endpoints Post-Deployment

After deployment, update the endpoints in Azure Portal:

1. Go to your Function App resource
2. Navigate to **Configuration** > **Application settings**
3. Update the `ENDPOINTS` variable with your endpoints as a JSON array:
   ```json
   ["https://your-app.azurewebsites.net/health", "https://api.example.com/status"]
   ```
4. Click **Save**

### Local Development

1. Install dependencies:
```bash
cd src
dotnet restore
```

2. Update `local.settings.json` with your test endpoints

3. Run locally:
```bash
func start
```

The function will start and execute based on the timer trigger schedule (default: every 5 minutes).

## Monitoring

The function automatically logs to Application Insights. View logs and metrics:

1. Go to your Function App in Azure Portal
2. Select **Application Insights** > **Transaction search** or **Logs**
3. Filter by custom dimensions or view live metrics

## Cost Estimation

- **Azure Functions (Consumption Plan)**: ~$0.20/month (1M free executions/month, 400K GB-seconds free)
- **Application Insights**: ~$0.50/month (with Log Analytics workspace)
- **Storage Account**: ~$0.05/month

**Total estimated monthly cost: < €1.00**

## Troubleshooting

### Function not executing

1. Check the timer trigger is enabled:
   ```bash
   az functionapp config appsettings list --name <function-app-name> --resource-group <resource-group>
   ```

2. Check Application Insights logs for errors

3. Verify endpoints are accessible from Azure regions

### Endpoints returning false positives

- Adjust `EXPECTED_STATUS_CODE` if your health endpoint returns something other than 200
- Check endpoint response times (5-minute timeout on function execution)

## Contributing

Contributions welcome! Please submit issues and pull requests.

## License

MIT