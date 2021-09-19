var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers().AddDapr();

// Configure and enable middlewares
var app = builder.Build();
app.UseCloudEvents();

app.MapGet("/order", async (Dapr.Client.DaprClient client) => 
    await client.GetStateAsync<Order>("statestore", "orders"));

app.MapPost("/neworder", async (Order o, Dapr.Client.DaprClient client) =>
    await client.SaveStateAsync<Order>("statestore", "orders", o));

app.Run();

public record Order(string OrderId);