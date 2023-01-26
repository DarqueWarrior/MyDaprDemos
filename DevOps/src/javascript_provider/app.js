const express = require("express");
const logger = require("./logger");
// const tracing = require("./tracing");
const { DaprClient, DaprServer, HttpMethod, CommunicationProtocolEnum } = require("@dapr/dapr");

const app = express();
app.use(express.json());
const port = parseInt(process.env.PORT || "5040");

// Names of the Dapr components
const serviceMethod = "score";
const serviceAppId = "processor";
const serviceTopicName = "scored";
const servicePubSubName = "pubsub";
const serviceStoreName = "statestore";

// This the method that will be called when the Dapr runtime gets a tweet
app.post("/tweets", async (req, res) => {
    logger.debug("Received tweet from Dapr");

    const tweet = req.body;
    if (!tweet) {
        logger.debug("Tweet body is empty");

        res.status(400).send({ error: "invalid content" });
        return;
    }

    // await tracer.startActiveSpan("queryActor.onActivate", async span => {

        let client = new DaprClient();

        // Save in state store for future use
        logger.debug("Storing tweet via Dapr with id: " + tweet.id_str);
        let response = await client.state.save(serviceStoreName, [{ key: tweet.id_str, value: tweet }]);

        // Call sentiment scoring service
        let body = { lang: tweet.lang, text: tweet.text };
        logger.debug("Calling processor via Dapr with body: " + JSON.stringify(body));
        try {
            response = await client.invoker.invoke(serviceAppId, serviceMethod, HttpMethod.POST, body);
            logger.debug("Processor response: " + JSON.stringify(response));
        } catch (error) {
            logger.error("Error calling processor: " + error);
            return res.status(200).send();
            // return res.status(500).send({ error: "error calling processor" });
        }

        // publish the tweet to the topic
        // Added the sentiment score to the tweet
        let analyzedTweet = {
            tweet: tweet,
            score: response.score
        };
        logger.debug("Publishing tweet with sentiment via Dapr: " + JSON.stringify(analyzedTweet));
        response = await client.pubsub.publish(servicePubSubName, serviceTopicName, analyzedTweet);

        res.status(200).send();

    //     span.end();
    // });
});

app.listen(port, () => logger.info(`Port: ${port}!`));