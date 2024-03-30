package room;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import java.net.URI;

import cartago.Artifact;
import cartago.OPERATION;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {

    private String dweetURI = "https://dweet.io/dweet/for/kai_exercise6";

    public void init() {
    }

    @OPERATION
    public void sendDweet(String action, String receiver, String performative, String content) {
        try {
            URI uri = new URI(dweetURI);

            String payload = "{ \"action\": \"" + action + "\", \"receiver\": \"" + receiver
                    + "\", \"performative\": \""
                    + performative + "\", \"content\": \"" + content + "\" }";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(uri)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();

            HttpClient client = HttpClient.newHttpClient();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                throw new RuntimeException("HTTP error code : " + response.statusCode());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
