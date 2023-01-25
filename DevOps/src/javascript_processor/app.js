const express = require("express");
const logger = require("./logger");
const tracing = require("./tracing");
const { context, propagation, trace, SpanStatusCode, SpanKind } = require("@opentelemetry/api");

const tracer = trace.getTracer(
    'processor-tracer'
);

const app = express();
app.use(express.json());
const port = parseInt(process.env.PORT || "5030");

// Cognitive Services API
// The KEY 1 value from Azure Portal, Keys and Endpoint section
const apiToken = process.env.AZURE_CS_TOKEN || "";

// The Endpoint value from Azure Portal, Keys and Endpoint section
const endpoint = process.env.AZURE_CS_ENDPOINT || "";

// The full URL to the sentiment service
const apiURL = `${endpoint}text/analytics/v2.1/sentiment`;

// This service provides this scoring method
app.post("/score", (req, res) => {
    logger.debug("Received tweet from provider: " + JSON.stringify(req.body));

    let lang = req.body.lang;
    let text = req.body.text;

    if (!text || !text.trim()) {
        res.status(400).send({ error: "text required" });
        return;
    }

    if (!lang || !lang.trim()) {
        lang = "en";
    }

    const reqBody = {
        documents: [
            {
                id: "1",
                language: lang,
                text: text,
            },
        ],
    };

    // Call cognitive service to score the tweet
    logger.debug("Invoking cognitive service");
    tracer.startActiveSpan("callazure/text/analytics/v2.1/sentiment", { kind: SpanKind.SERVER }, context.active(),
        // tracer.startActiveSpan("callazure/text/analytics/v2.1/sentiment",
        span => {
            fetch(apiURL, {
                method: "POST",
                body: JSON.stringify(reqBody),
                headers: {
                    "Content-Type": "application/json",
                    "Ocp-Apim-Subscription-Key": apiToken,
                },
            })
                .then((_res) => {
                    // To avoid expensive computations, check that span is recording
                    // before setting any attributes.
                    if (span.isRecording()) {
                        // Add an attribute to the span
                        span.setAttribute('response.code', _res.status);
                    }

                    if (!_res.ok) {
                        logger.debug("error invoking cognitive service");
                        res.status(400).send({ error: "error invoking cognitive service" });

                        span.setStatus({ code: SpanStatusCode.ERROR, message: "error invoking cognitive service" });
                        span.end();
                        return;
                    }
                    return _res.json();
                })
                .then((_resp) => {
                    // Send the response back to the caller.
                    const result = _resp.documents[0];

                    // Check result is valid
                    if (!result) {
                        logger.debug("Response: result was undefined");
                        // To avoid expensive computations, check that span is recording
                        // before setting any attributes.
                        if (span.isRecording()) {
                            // Add an attribute to the span
                            span.setAttribute('response.data.score', 'undefined');
                        }
                    } else {
                        // To avoid expensive computations, check that span is recording
                        // before setting any attributes.
                        if (span.isRecording()) {
                            // Add an attribute to the span
                            span.setAttribute('response.data.score', result.score);
                        }
                    }

                    span.end();

                    logger.debug("Response:" + JSON.stringify(result));
                    res.status(200).send(result);

                    return;
                })
                .catch((error) => {
                    span.recordException(error);
                    span.setStatus({ code: SpanStatusCode.ERROR, message: String(error) });
                    span.end();

                    logger.error("error:" + error);
                    res.status(500).send({ message: error });
                });
        });
});

// Root get that just returns the configured values.
app.get("/", (req, res) => {
    let dateTime = new Date();
    logger.debug("sentiment endpoint: " + endpoint);
    logger.debug("sentiment apiURL: " + apiURL);
    res.status(200).json({
        message: "hi, nothing to see here, try => POST /score",
        endpoint: endpoint,
        apiURL: apiURL,
        date: dateTime.toISOString(),
    });
});

app.listen(port, () => logger.info(`Port: ${port}!`));