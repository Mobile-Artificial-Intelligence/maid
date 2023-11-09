import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maid/utilities/host.dart';

class HostedGeneration {
  static void prompt(String input) async {
    final url = Uri.parse(Host.urlController.text);
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "model": "llama2:7b",
      "prompt": prompt,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Assuming the server returns a JSON object with the generated text
        var responseData = json.decode(response.body);
        // You need to check the structure of your response and access it accordingly
        //return responseData['generatedText']; // This key might be different based on your actual response
      } else {
        // Handle the case where the server returns a non-200 status code
        //return 'Error: Server returned a status of ${response.statusCode}';
      }
    } catch (e) {
      // Handle any errors that occur during the POST
      //return 'Error: $e';
    }
  }
}