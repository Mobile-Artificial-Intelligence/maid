import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maid/utilities/host.dart';
import 'package:maid/utilities/message_manager.dart';

class HostedGeneration {
  static void prompt(String input) async {
    final url = Uri.parse("${Host.urlController.text}/api/generate");
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "model": "llama2:7b", // TODO: Make this configurable
      "prompt": input,
    });

    try {
      var request = http.Request("POST", url)
        ..headers.addAll(headers)
        ..body = body;

      final streamedResponse = await request.send();

      await for (var value in streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        final data = json.decode(value);
        final responseText = data['response'] as String?;
        final done = data['done'] as bool?;

        if (responseText != null && responseText.isNotEmpty) {
          MessageManager.stream(responseText);
        }

        if (done ?? false) {
          break;
        }
      }
    } catch (e) {
      // Handle any errors that occur during the POST
      print('Error: $e');
    }
  }
}