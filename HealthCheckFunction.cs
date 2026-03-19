using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Extensions.Timer;
using Microsoft.Extensions.Logging;

namespace FakeAlwaysOn;

public sealed class HealthCheckFunction
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<HealthCheckFunction> _logger;

    public HealthCheckFunction(IHttpClientFactory httpClientFactory, ILogger<HealthCheckFunction> logger)
    {
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    [Function("HealthCheck")]
    public async Task Run([TimerTrigger("%TIMER_INTERVAL%", RunOnStartup = false)] TimerInfo timer)
    {
        _logger.LogInformation("Health check started at {TimestampUtc}", DateTime.UtcNow);

        var endpointsJson = Environment.GetEnvironmentVariable("ENDPOINTS") ?? "[]";
        var expectedStatusCode = int.TryParse(Environment.GetEnvironmentVariable("EXPECTED_STATUS_CODE"), out var parsed)
            ? parsed
            : (int)HttpStatusCode.OK;

        List<string>? endpoints;
        try
        {
            endpoints = JsonSerializer.Deserialize<List<string>>(endpointsJson);
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "ENDPOINTS is not valid JSON. Value: {EndpointsJson}", endpointsJson);
            return;
        }

        if (endpoints is null || endpoints.Count == 0)
        {
            _logger.LogWarning("No endpoints configured. Set ENDPOINTS to a JSON array of URLs.");
            return;
        }

        var client = _httpClientFactory.CreateClient();
        var checks = endpoints.Select(endpoint => CheckEndpointAsync(client, endpoint, expectedStatusCode));
        var results = await Task.WhenAll(checks);

        var successCount = results.Count(static x => x);
        _logger.LogInformation("Health check completed: {Succeeded}/{Total} endpoints matched expected status {ExpectedStatusCode}", successCount, endpoints.Count, expectedStatusCode);

        if (timer.IsPastDue)
        {
            _logger.LogWarning("Timer trigger was past due.");
        }
    }

    private async Task<bool> CheckEndpointAsync(HttpClient client, string endpoint, int expectedStatusCode)
    {
        try
        {
            using var response = await client.GetAsync(endpoint);
            var statusCode = (int)response.StatusCode;
            var success = statusCode == expectedStatusCode;

            if (success)
            {
                _logger.LogInformation("Endpoint OK: {Endpoint} returned {StatusCode}", endpoint, statusCode);
            }
            else
            {
                _logger.LogWarning("Endpoint mismatch: {Endpoint} returned {StatusCode}, expected {ExpectedStatusCode}", endpoint, statusCode, expectedStatusCode);
            }

            return success;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Request failed for endpoint {Endpoint}", endpoint);
            return false;
        }
    }
}
