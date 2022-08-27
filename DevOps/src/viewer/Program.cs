var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers().AddDapr();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "temp", Version = "v1" });
});

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddSignalR();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "temp v1"));
}
else
{
    app.UseExceptionHandler("/Error");
}

app.UseStaticFiles();
app.UseCloudEvents();
app.UseRouting();
app.UseAuthorization();
app.UseEndpoints(endpoints => 
{
    endpoints.MapSubscribeHandler();
    endpoints.MapHub<viewer.Hubs.TweetHub>("/tweetHub");
});

app.MapControllers();

app.MapRazorPages();

app.Run();