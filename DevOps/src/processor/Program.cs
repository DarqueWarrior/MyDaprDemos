using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// Configure and enable middlewares
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

string API_TOKEN = Environment.GetEnvironmentVariable("CS_TOKEN") ?? "";
string ENDPOINT = Environment.GetEnvironmentVariable("CS_ENDPOINT ") ?? "";
// The full URL to the sentiment service
var apiURL = $"{ENDPOINT}text/analytics/v2.1/sentiment";

app.MapPost("/score", (Tweet t) =>
 {
     app.Logger.LogInformation($"processing tweet: {t.Author.Name}, {t.Language}, {t.Author.Picture}");
     return new AnalyzedTweet(t, new SentimentScore("unknown", 0.5f));
 });

await app.RunAsync();

app.Run();

public record TwitterUser([property: JsonPropertyName("screen_name")] string ScreenName, 
                          [property: JsonPropertyName("profile_image_url_https")] string Picture, 
                          string Name);

public record Tweet([property: JsonPropertyName("id_str")] string Id, 
                    [property: JsonPropertyName("lang")] string Language,
                    [property: JsonPropertyName("user")] TwitterUser Author,
                    [property: JsonPropertyName("full_text")] string FullText,
                    string Text);

public record SentimentScore(string Sentiment, float confidence);

public record AnalyzedTweet(Tweet Tweet, 
                            SentimentScore Sentiment);