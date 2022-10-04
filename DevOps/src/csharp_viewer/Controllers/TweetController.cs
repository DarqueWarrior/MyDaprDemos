using viewer.Hubs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace viewer.Controllers;

[ApiController]
[Route("[controller]")]
public class TweetController : ControllerBase
{
    private readonly IHubContext<TweetHub> _hub;
    private readonly ILogger<TweetController> _logger;

    public TweetController(ILogger<TweetController> logger, IHubContext<TweetHub> hub)
    {
        _hub = hub;
        _logger = logger;
    }

    [HttpPost]
    [Dapr.Topic("pubsub", "scored")]
    public async void PostTweet(object tweet)
    {
        this._logger.LogInformation("Viewer received tweet");
        await this._hub.Clients.All.SendAsync("ReceiveTweet", tweet);
    }
}