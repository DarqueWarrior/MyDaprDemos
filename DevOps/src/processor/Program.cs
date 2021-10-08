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

app.MapGet("/", () => API_TOKEN);

app.MapPost("/score", (object o) =>
 {
     app.Logger.LogInformation("processing tweet");
     return o;
 });

await app.RunAsync();

app.Run();
