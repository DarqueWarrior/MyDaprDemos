var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers().AddDapr();

// Configure and enable middlewares
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapPost("/tweets", async (object o, Dapr.Client.DaprClient client) =>
 {
     app.Logger.LogInformation("/tweets invoked...");
     var scoredTweet = await client.InvokeMethodAsync<object, object>("processor", "score", o);
     await client.SaveStateAsync<object>("statestore", "tweet-store", scoredTweet);
     await client.PublishEventAsync<object>("pubsub", "scored", scoredTweet);
 });

await app.RunAsync();

app.Run();
