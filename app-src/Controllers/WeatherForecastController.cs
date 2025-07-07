using Microsoft.AspNetCore.Mvc;

namespace VibesApp.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;

    public WeatherForecastController(ILogger<WeatherForecastController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public IActionResult Get([FromQuery] int days = 5)
    {
        using var activity = _logger.BeginScope(new Dictionary<string, object>
        {
            ["Action"] = "GetWeatherForecast",
            ["Controller"] = "WeatherForecast",
            ["RequestedDays"] = days
        });

        _logger.LogInformation("Getting weather forecast for {Days} days", days);
        
        try
        {
            if (days < 1 || days > 30)
            {
                _logger.LogWarning("Invalid number of days requested: {Days}. Must be between 1 and 30", days);
                return BadRequest(new { Error = "Days must be between 1 and 30" });
            }

            var forecast = Enumerable.Range(1, days).Select(index => new WeatherForecast
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })
            .ToArray();

            _logger.LogInformation("Weather forecast generated successfully for {Days} days. Generated {Count} entries", 
                days, forecast.Length);

            return Ok(forecast);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating weather forecast for {Days} days", days);
            return StatusCode(500, new { Error = "Failed to generate weather forecast" });
        }
    }
}