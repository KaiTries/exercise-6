package room;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.net.URI;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {

    private String dweetURI = "https://dweet.io/dweet/for/kai_exercise6";

    public void init() {
    }

    @OPERATION
    public void sendDweet(String action, String receiver, String performative, String content, OpFeedbackParam<String> response) {
        try {
            URI uri = new URI(dweetURI);
            // thanks to jonas for the nicely structured payload body
            String payload = "{ \"action\": \"" + action + "\", \"receiver\": \"" + receiver
                    + "\", \"performative\": \""
                    + performative + "\", \"content\": \"" + content + "\" }";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(uri)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();

            HttpClient client = HttpClient.newHttpClient();

            HttpResponse<String> res = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (res.statusCode() != 200) {
                throw new RuntimeException("HTTP error code : " + res.statusCode());
            }
            // parse the returned JSON and return the node value of the "this" key
            JsonNode node = new ObjectMapper().readTree(res.body());
            String dweet = node.get("this").asText();
            response.set(dweet);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
