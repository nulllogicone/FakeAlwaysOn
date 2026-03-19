using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace FakeAlwaysOn
{
    public static class HealthCheckFunction
    {
        private static readonly HttpClient client = new HttpClient();

        [FunctionName("HealthCheck")]
        public static async Task Run(
            [TimerTrigger("0 */5 * * * *")] TimerInfo myTimer,
            ILogger log)
        {
            log.LogInformation($"Health check function started at {DateTime.UtcNow:O}");

            try
            {
                // Get configuration from environment variables
                var endpointsJson = Environment.GetEnvironmentVariable("ENDPOINTS") ?? "[]";
                var expectedStatusCode = int.TryParse(
                    Environment.GetEnvironmentVariable("EXPECTED_STATUS_CODE") ?? "200",
                    out var code) ? code : 200;

                var endpoints = JsonSerializer.Deserialize<List<string>>(endpointsJson) ?? new List<string>();

                if (!endpoints.Any())
                {
                    log.LogWarning("No endpoints configured in ENDPOINTS environment variable");
                    return;
                }

                log.LogInformation($"Checking {endpoints.Count} endpoints with expected status code {expectedStatusCode}");

                var tasks = endpoints.Select(endpoint => CheckEndpointAsync(endpoint, expectedStatusCode, log));
                var results = await Task.WhenAll(tasks);

                var successCount = results.Count(r => r);
                log.LogInformation($"Health check completed: {successCount}/{endpoints.Count} endpoints passed");

                if (myTimer. isPastDue)
                {
                    log.LogWarning("Health check function is running late");
                }
            }
            catch (Exception ex)
            {
                log.LogError($"Error during health check: {ex.Message}");
                throw;
            }
        }

        private static async Task<bool> CheckEndpointAsync(string endpoint, int expectedStatusCode, ILogger log)
        {
            try
            {
                var response = await client.GetAsync(endpoint);
                var statusCode = (int)response.StatusCode;
                var success = statusCode >= 200 && statusCode < 300;

                if (success)
                {
                    log.LogInformation($"✓ {endpoint} returned {statusCode}");
                }
                else
                {
                    log.LogWarning($"✗ {endpoint} returned {statusCode}");
                }

                return success;
            }
            catch (Exception ex)
            {
                log.LogError($"✗ Failed to check {endpoint}: {ex.Message}");
                return false;
            }
        }
    }
}
