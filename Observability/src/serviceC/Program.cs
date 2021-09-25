var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers().AddDapr();

// Configure and enable middlewares
var app = builder.Build();
app.UseCloudEvents();
app.UseRouting();
app.UseEndpoints(endpoints => endpoints.MapSubscribeHandler());

app.MapPost("/revieworder", (Order order) =>
{
    app.Logger.LogInformation($"Reviewing order {order.OrderId} that was processed at {order.State}");
}).WithTopic("pubsub", "processedorders");

app.Run();

public record Order(string OrderId, string State);