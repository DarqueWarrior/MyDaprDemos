using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace viewer.Hubs
{
    public class TweetHub : Hub
    {
        public async Task SendMessage(string user, string message)
        {
            await Clients.All.SendAsync("ReceiveMessage", user, message);
        }
    }
}