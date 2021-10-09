using Microsoft.AspNetCore.Mvc;

namespace viewer.Controllers;

[ApiController]
[Route("[controller]")]
public class TweetController : ControllerBase
{
    private readonly ILogger<TweetController> _logger;

    public TweetController(ILogger<TweetController> logger)
    {
        _logger = logger;
    }
    
    [HttpPost]
    [Dapr.Topic("pubsub", "scored")]
    public void PostTweet(object model)
    {
        this._logger.LogInformation("Viewer");
    }
}
