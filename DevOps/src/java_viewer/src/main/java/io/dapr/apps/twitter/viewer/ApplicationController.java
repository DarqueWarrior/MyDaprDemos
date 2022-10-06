/*
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT License.
 */

package io.dapr.apps.twitter.viewer;

import java.io.IOException;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

import io.dapr.Topic;
import io.dapr.client.domain.CloudEvent;
import reactor.core.publisher.Mono;

@RestController
public class ApplicationController {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(ApplicationController.class);

    private static final String PUBSUB = "pubsub";

    @Topic(name = "scored", pubsubName = PUBSUB)
    @PostMapping(value = "/tweets")
    @ResponseStatus(HttpStatus.OK)
    @ResponseBody
    public void tweet(@RequestBody(required = false) CloudEvent<?> event) throws IOException {
        String data = OBJECT_MAPPER.writeValueAsString(event.getData());
        log.info("Received cloud event: " + data);
        WebSocketPubSub.INSTANCE.send(data);
    }

    @GetMapping(path = "/health")
    public Mono<Void> health() {
        return Mono.empty();
    }
}
