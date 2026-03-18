---
description: Instructions for Copilot to follow when working on the FakeAlwaysOn project
---

# FakeAlwaysOn Project Instructions

## Overview
This project implements a fake "Always On" feature for Azure App Services on free/cheapest tiers by using an Azure Functions app on Consumption plan to periodically ping health endpoints.

## Project Structure
- `src/`: Source code for Azure Functions
- `infrastructure/`: Bicep templates for Azure resources
- `.azure/`: Azure deployment configuration

## Key Requirements
- Minimal cost (Consumption plan Functions)
- Configurable endpoints and ping intervals
- Easy deployment via CI/CD
- Local testing capability
- Azure deployment with "Deploy to Azure" button

## Design Principles
- Keep it simple and minimal
- Use Consumption plan for cost efficiency
- Configurable via environment variables
- Proper error handling and logging
- Easy to extend for additional features

## Development Workflow
1. Local development and testing
2. Infrastructure as Code with Bicep
3. AZD for deployment
4. GitHub Actions for CI/CD

## Code Standards
- Clean, readable code
- Proper error handling
- Logging for debugging
- Environment variable configuration
- No hardcoded values

## Deployment
- Use AZD for infrastructure and deployment
- Store secrets in Key Vault
- Enable Application Insights for monitoring
- Support multiple environments (dev, prod)