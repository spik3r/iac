var builder = WebApplication.CreateBuilder(args);

// Configure for Azure App Service
var port = Environment.GetEnvironmentVariable("PORT") ?? "80";
builder.WebHost.UseUrls($"http://*:{port}");

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Don't use HTTPS redirection in Azure App Service containers
// app.UseHttpsRedirection();

app.UseAuthorization();
app.MapControllers();

// Add a simple health check endpoint
app.MapGet("/health", () => new { Status = "Healthy", Timestamp = DateTime.UtcNow });

// Add a simple info endpoint
app.MapGet("/", () => new { 
    Message = "Welcome to Vibes .NET 8 Web API", 
    Environment = app.Environment.EnvironmentName,
    Version = "1.0.0",
    Port = Environment.GetEnvironmentVariable("PORT") ?? "80"
});

app.Run();