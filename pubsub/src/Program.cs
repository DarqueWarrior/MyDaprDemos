var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.UseCloudEvents();

app.MapPost("/", (object model) => app.Logger.LogInformation("Got It!"));

app.Run();