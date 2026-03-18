# Fake: Always On Feature for free

> About: Azure App Services - AlwaysOn Feature - only in > 50 EUR/month tier

I run all development on cheapest sku, full solution costs < 40 EUR/month. But this also means my WebApi has always a heavy cold start when I call it after a while. I want it Always On!
Can we not fake it for free? The consumption tier function app could make every x minutes a request to the health endpoint. 

## Acceptance criteria

- The full feature is deployed automatically by IaC CI/CD and all secrets are in keyvault. Costs should be minimal.
- A convenient blue 'Deploay to Azure' button on GitHub readme preview allows easy installation to any tenant.
- It should be easy to configure different target endpoints with frequency and result code handling

##