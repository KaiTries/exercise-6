package room;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import java.io.IOException;
import java.net.URI;
import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;



/**
 * A CArtAgO artifact that provides an operation for sending messages to agents 
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {


    private String dweetURI = "https://dweet.io/dweet/for/kai_exercise6?";

    @OPERATION
    void sendDweet(String message, OpFeedbackParam<String> response) {
        String requestURI = dweetURI + message;
        // Send the message to the dweet.io API
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(requestURI))
            .build();

        // Send the request to the dweet.io API
        HttpResponse<String> httpResponse = null;
        try {
            httpResponse = client.send(request, HttpResponse.BodyHandlers.ofString());
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }


        // Set the response to the dweet response
        response.set(httpResponse.body());
    }
    
}
