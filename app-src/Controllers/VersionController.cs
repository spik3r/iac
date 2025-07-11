using Microsoft.AspNetCore.Mvc;
using System.Reflection;

namespace VibesApp.Controllers;

[ApiController]
[Route("[controller]")]
public class VersionController : ControllerBase
{
    private readonly ILogger<VersionController> _logger;

    public VersionController(ILogger<VersionController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Get()
    {
        using var activity = _logger.BeginScope(new Dictionary<string, object>
        {
            ["Action"] = "GetVersion",
            ["Controller"] = "Version"
        });

        _logger.LogInformation("Getting version information");

        try
        {
            var assembly = Assembly.GetExecutingAssembly();
            var version = assembly.GetName().Version?.ToString() ?? "1.0.0";
            
            // Try to get build version from environment variable (set by pipeline)
            var buildVersion = Environment.GetEnvironmentVariable("BUILD_VERSION") ?? version;
            var buildNumber = Environment.GetEnvironmentVariable("BUILD_NUMBER") ?? "local";
            var buildDate = Environment.GetEnvironmentVariable("BUILD_DATE") ?? DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ");
            var gitCommit = Environment.GetEnvironmentVariable("GIT_COMMIT") ?? "unknown";
            var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";

            var versionInfo = new
            {
                Version = buildVersion,
                BuildNumber = buildNumber,
                BuildDate = buildDate,
                GitCommit = gitCommit,
                Environment = environment,
                MachineName = Environment.MachineName,
                Timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
            };

            _logger.LogInformation("Version information retrieved successfully. Version: {Version}, Environment: {Environment}", 
                buildVersion, environment);

            return Ok(versionInfo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving version information");
            return StatusCode(500, new { Error = "Failed to retrieve version information" });
        }
    }

    [HttpGet("health")]
    public IActionResult Health()
    {
        using var activity = _logger.BeginScope(new Dictionary<string, object>
        {
            ["Action"] = "HealthCheck",
            ["Controller"] = "Version"
        });

        _logger.LogInformation("Health check requested");
        
        try
        {
            var buildVersion = Environment.GetEnvironmentVariable("BUILD_VERSION") ?? "1.0.0";
            var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";
            
            var healthInfo = new { 
                Status = "Healthy", 
                Timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"),
                Version = buildVersion,
                Environment = environment,
                MachineName = Environment.MachineName
            };

            _logger.LogInformation("Health check completed successfully. Status: {Status}, Version: {Version}", 
                "Healthy", buildVersion);

            return Ok(healthInfo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Health check failed");
            return StatusCode(500, new { 
                Status = "Unhealthy", 
                Timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"),
                Error = "Health check failed"
            });
        }
    }

    [HttpGet("test-logs")]
    public IActionResult TestLogs()
    {
        using var activity = _logger.BeginScope(new Dictionary<string, object>
        {
            ["Action"] = "TestLogs",
            ["Controller"] = "Version",
            ["TestId"] = Guid.NewGuid().ToString()
        });

        _logger.LogDebug("DEBUG: This is a debug message for testing Application Insights");
        _logger.LogInformation("INFO: Testing Application Insights logging integration");
        _logger.LogWarning("WARNING: This is a test warning message");
        
        // Log with structured data
        _logger.LogInformation("Structured log test: User {UserId} performed action {Action} at {Timestamp}", 
            "test-user-123", "test-logs", DateTime.UtcNow);

        try
        {
            // Simulate some work
            var random = new Random();
            var delay = random.Next(10, 100);
            Thread.Sleep(delay);
            
            _logger.LogInformation("Test operation completed successfully after {DelayMs}ms", delay);
            
            return Ok(new { 
                Message = "Test logs generated successfully",
                LogLevels = new[] { "Debug", "Information", "Warning" },
                Timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"),
                TestId = activity.ToString()
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "ERROR: Test logs endpoint failed");
            return StatusCode(500, new { Error = "Test failed" });
        }
    }
}