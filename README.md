# Fake: Always On Feature for free

> About: Azure App Services - AlwaysOn Feature - not available in free plan

I enjoy to run development experiments on cheapest sku, but this means my Web app or Apis always have a slow cold start when I call it after a while. I want them Always On!
This project simulates the feature in a very cheap manner:  Serveless Azure Function in consumption tier makes every x minutes a request to configurable  endpoints. 

## Quick Deploy

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnulllogicone%2FFakeAlwaysOn%2Fmain%2F.azure%2Fazuredeploy.json)



## Implementation details

### Lowest cost on Azure
- Consumption plan for Azure Functions
- Configurable array of endpoints to ping
- Configurable interval of ping






### Configuration

The health check function uses environment variables for configuration:

| Variable | Default | Description |
|----------|---------|-------------|
| `ENDPOINTS` | `["https://example.com/health"]` | JSON array of endpoints to health check |
| `EXPECTED_STATUS_CODE` | `200` | Expected HTTP status code for healthy response |
| `TIMER_INTERVAL` | `0 */5 * * * *` | CRON expression for check frequency (every 5 minutes) |



## Cost Estimation

- **Azure Functions (Consumption Plan)**: ~$0.20/month (1M free executions/month, 400K GB-seconds free)
- **Application Insights**: ~$0.50/month (with Log Analytics workspace)
- **Storage Account**: ~$0.05/month

**Total estimated monthly cost: < €1.00**
