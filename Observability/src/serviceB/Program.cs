var app = WebApplication.Create(args);

app.MapPost("/process", (Order o) =>
 {
     app.Logger.LogInformation("processing order");
     return new Order(o.OrderId, $"Processed at {DateTime.UtcNow}");
 });

await app.RunAsync();

public record Order(string OrderId, string State);