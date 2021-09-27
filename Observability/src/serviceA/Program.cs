var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers().AddDapr();

// Configure and enable middlewares
var app = builder.Build();
app.UseCloudEvents();
app.UseRouting();
app.UseEndpoints(endpoints => endpoints.MapSubscribeHandler());

app.MapPost("/incomingorders", async (Order o, Dapr.Client.DaprClient client) =>
{
    app.Logger.LogInformation("order received");
    app.Logger.LogInformation("calling serviceB");
    var processedOrder = await client.InvokeMethodAsync<Order, Order>("serviceB", "process", o);
    app.Logger.LogInformation("saving to state store");
    await client.SaveStateAsync<Order>("statestore", "orders", processedOrder);
    app.Logger.LogInformation("publish to processedorders");
    await client.PublishEventAsync<Order>("pubsub", "processedorders", processedOrder);
}).WithTopic("pubsub", "incomingorders");

app.Run();

public record Order(string OrderId, string State);