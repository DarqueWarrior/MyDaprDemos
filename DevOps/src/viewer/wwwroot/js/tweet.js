"use strict";

var connection = new signalR.HubConnectionBuilder().withUrl("/tweetHub").build();

connection.on("ReceiveTweet", function (t) {
    var log = document.getElementById("tweets");

    function appendLog(item) {
        var doScroll = log.scrollTop > log.scrollHeight - log.clientHeight - 1;
        log.appendChild(item);
        if (doScroll) {
            log.scrollTop = log.scrollHeight - log.clientHeight;
        }
    }

    var scoreStr = "unknown";
    var scoreAlt = "unknown: ?";

    if (t.sentiment.sentiment.length > 0) {
        scoreStr = t.sentiment.sentiment;
        scoreAlt = scoreStr + ": " + t.sentiment.confidence;
    }

    var tweetText = t.tweet.text;
    if (t.tweet.fullText != null) {
        tweetText = t.tweet.full_text;
    }

    var item = document.createElement("div");
    item.className = "item";

    var postURL = t.tweet.user.name;
    if (t.tweet.user.screen_name) {
        postURL = `
        <b>${t.tweet.user.screen_name}</b>
        <a href='https://twitter.com/${t.tweet.user.screen_name}/status/${t.tweet.id_str}' target='_blank'><img src='img/tw.svg' class='tweet-link' /></a>
        `;
    }

    var tweetMsg = `
    <img src='${t.tweet.user.profile_image_url_https}' class='profile-pic' />
    <div class='item-text'>
        <img src='img/${scoreStr}.svg' title='${scoreAlt}' class='sentiment' />${postURL}<br /><i>${tweetText}</i>
    </div>
    `;
    
    item.innerHTML = tweetMsg;
    appendLog(item);
});

connection.start().then(function () {
    var connDiv = document.getElementById("connection-status");
    connDiv.innerText = "open";
}).catch(function (err) {
    return console.error(err.toString());
});