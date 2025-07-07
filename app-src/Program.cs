using Serilog;
using Serilog.Events;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog with Application Insights
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}")
    .WriteTo.ApplicationInsights(
        connectionString: builder.Configuration.GetConnectionString("ApplicationInsights"),
        telemetryConverter: new Serilog.Sinks.ApplicationInsights.TelemetryConverters.TraceTelemetryConverter())
    .CreateLogger();

builder.Host.UseSerilog();

// Configure for Azure App Service
var port = Environment.GetEnvironmentVariable("PORT") ?? "80";
builder.WebHost.UseUrls($"http://*:{port}");

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { 
        Title = "Vibes API", 
        Version = "v1",
        Description = "A simple ASP.NET Core Web API with Serilog and Application Insights"
    });
});

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.ConnectionString = builder.Configuration.GetConnectionString("ApplicationInsights");
});

var app = builder.Build();

// Configure the HTTP request pipeline.
// Enable Swagger in all environments except Production
if (!app.Environment.IsProduction())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Vibes API v1");
        c.RoutePrefix = "swagger";
        c.DocumentTitle = $"Vibes API - {app.Environment.EnvironmentName}";
    });
}

// Add Serilog request logging
app.UseSerilogRequestLogging(options =>
{
    options.MessageTemplate = "HTTP {RequestMethod} {RequestPath} responded {StatusCode} in {Elapsed:0.0000} ms";
    options.GetLevel = (httpContext, elapsed, ex) => ex != null
        ? LogEventLevel.Error 
        : httpContext.Response.StatusCode > 499 
            ? LogEventLevel.Error 
            : LogEventLevel.Information;
    options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
    {
        diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
        diagnosticContext.Set("RequestScheme", httpContext.Request.Scheme);
        diagnosticContext.Set("UserAgent", httpContext.Request.Headers["User-Agent"].FirstOrDefault());
        diagnosticContext.Set("RemoteIP", httpContext.Connection.RemoteIpAddress?.ToString());
    };
});

// Don't use HTTPS redirection in Azure App Service containers
// app.UseHttpsRedirection();

app.UseAuthorization();
app.MapControllers();

// Add a simple health check endpoint
app.MapGet("/health", (ILogger<Program> logger) => 
{
    logger.LogInformation("Health check endpoint accessed");
    return new { Status = "Healthy", Timestamp = DateTime.UtcNow };
});

// Add a simple info endpoint
app.MapGet("/", (ILogger<Program> logger) => 
{
    logger.LogInformation("Root endpoint accessed");
    return new { 
        Message = "Welcome to Vibes .NET 8 Web API", 
        Environment = app.Environment.EnvironmentName,
        Version = Environment.GetEnvironmentVariable("BUILD_VERSION") ?? "1.0.0",
        Port = Environment.GetEnvironmentVariable("PORT") ?? "80",
        SwaggerEnabled = !app.Environment.IsProduction()
    };
});

try
{
    Log.Information("Starting Vibes Web API");
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}