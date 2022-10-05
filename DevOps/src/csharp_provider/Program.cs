using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers().AddDapr();

// Configure and enable middlewares
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapPost("/tweets", async (Tweet t, Dapr.Client.DaprClient client) =>
 {
     app.Logger.LogInformation("/tweets invoked...");
     var scoredTweet = await client.InvokeMethodAsync<Tweet, AnalyzedTweet>("processor", "score", t);
     
     app.Logger.LogInformation("/tweet scored, saving to state store");
     await client.SaveStateAsync<AnalyzedTweet>("statestore", t.Id, scoredTweet);
     
     app.Logger.LogInformation("/tweet saved, posting to pubsub");
     await client.PublishEventAsync<AnalyzedTweet>("pubsub", "scored", scoredTweet);
     
     app.Logger.LogInformation("/tweet processed");
 });

await app.RunAsync();

public record TwitterUser([property: JsonPropertyName("screen_name")] string ScreenName, 
                          [property: JsonPropertyName("profile_image_url_https")] string Picture, 
                          string Name);

public record Tweet([property: JsonPropertyName("id_str")] string Id, 
                    [property: JsonPropertyName("lang")] string Language,
                    [property: JsonPropertyName("user")] TwitterUser Author,
                    [property: JsonPropertyName("full_text")] string FullText,
                    string Text);

public record AnalyzedTweet(Tweet Tweet,
                            float score);