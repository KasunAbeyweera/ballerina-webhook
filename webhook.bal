import ballerina/websub;
import ballerina/io;
import ballerina/email;

configurable string authT = ?;
configurable string email = ?;
configurable string password = ?;
configurable string reciverEmail = ?;

email:SmtpClient smtpClient = check new ("smtp.email.com", email, password);

function sendEmail(string to, string subject, string body) returns error? {
     email:Error? response = smtpClient->send(
        [to],
        subject,
        email,
        body = body,
        cc = [],
        bcc = [],
        sender = email,
        replyTo = []
        );
        return response;
        }

@websub:SubscriberServiceConfig {
    target: [
        "https://api.github.com/hub",
        "https://github.com/KasunAbeyweera/webhook-test/events/*.json"
    ],
    callback: "https://297f4ba2-047f-47f6-87f5-18b3403fd55d-dev.e1-us-east-azure.choreoapis.dev/alki/webhook/v1.0",
    httpConfig: {
        auth: {
            token: authT
        }
    }
}
service /events on new websub:Listener(9090) {
    remote function onEventNotification(websub:ContentDistributionMessage event)
                        returns error? {
        var retrievedContent = event.content;
        if (retrievedContent is json) {
            if (retrievedContent.action is string) {
                error? sendEmailResult = sendEmail(reciverEmail, "Webhook",<string>retrievedContent);
                if sendEmailResult is error {

                }
                io:println("Action performed: ", retrievedContent.action);
            }
        } else {
            io:println("Unrecognized content type, hence ignoring");
        }
    }
}
