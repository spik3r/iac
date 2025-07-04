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
        _logger.LogInformation("Getting version information");

        var assembly = Assembly.GetExecutingAssembly();
        var version = assembly.GetName().Version?.ToString() ?? "1.0.0";
        
        // Try to get build version from environment variable (set by pipeline)
        var buildVersion = Environment.GetEnvironmentVariable("BUILD_VERSION") ?? version;
        var buildNumber = Environment.GetEnvironmentVariable("BUILD_NUMBER") ?? "local";
        var buildDate = Environment.GetEnvironmentVariable("BUILD_DATE") ?? DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ");
        var gitCommit = Environment.GetEnvironmentVariable("GIT_COMMIT") ?? "unknown";

        var versionInfo = new
        {
            Version = buildVersion,
            BuildNumber = buildNumber,
            BuildDate = buildDate,
            GitCommit = gitCommit,
            Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development",
            MachineName = Environment.MachineName,
            Timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
        };

        return Ok(versionInfo);
    }

    [HttpGet("health")]
    public IActionResult Health()
    {
        _logger.LogInformation("Health check requested");
        
        return Ok(new { 
            Status = "Healthy", 
            Timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"),
            Version = Environment.GetEnvironmentVariable("BUILD_VERSION") ?? "1.0.0"
        });
    }
}