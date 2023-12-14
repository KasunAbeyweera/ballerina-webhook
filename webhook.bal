import ballerina/websub;
import ballerina/io;


configurable string authToken = ?;

@websub:SubscriberServiceConfig {
    target: [
        "https://api.github.com/hub", 
        "https://github.com/KasunAbeyweera/webhook-test/events/*.json" //Add teh correct path to required repo
    ],
    callback: "https://297f4ba2-047f-47f6-87f5-18b3403fd55d-dev.e1-us-east-azure.choreoapis.dev/alki/webhook/v1.0", // Add the ngrok URL 
    httpConfig: {
        auth: {
            token: authToken
        }
    }
}
service /events on new websub:Listener(9090) {
    remote function onEventNotification(websub:ContentDistributionMessage event) 
                        returns error? {
        var retrievedContent = event.content;
        if (retrievedContent is json) {
            if (retrievedContent.action is string){
                io:println("Action performed: ", retrievedContent.action);
            }
        } else {
            io:println("Unrecognized content type, hence ignoring");
        }
    }
}