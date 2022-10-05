import os
import json
import logging

from dapr.clients import DaprClient
from dapr.ext.grpc import App, BindingRequest

APP_PORT = os.getenv("APP_PORT", "5040")

app = App()


@app.binding('tweets')
def binding(request: BindingRequest):
    payload = request.text()
    m = json.loads(payload)

    logging.info(m)

    with DaprClient() as d:
        logging.info('/tweets invoked...')
        d.save_state('statestore', m['id_str'], payload)
        
        logging.info('/tweet scored, saving to state store')
        resp = d.invoke_method('processor', 'score', payload, http_verb='POST')
        scoredTweet = json.loads(resp.data)
        
        logging.info('/tweet saved, posting to pubsub')
        d.publish_event("pubsub", "scored", json.dumps(
            scoredTweet), data_content_type='application/json')
        
        logging.info('/tweet processed')


def main():
    app.run(APP_PORT)


if __name__ == "__main__":
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)

    main()
