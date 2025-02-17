part of 'package:maid/main.dart';

class OllamaUtilities {
  static Future<bool> checkForOllama(Uri url) async {
    final request = http.Request("GET", url);
    final headers = {
      "Accept": "application/json",
    };

    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode == 200) {
      log('Found Ollama at ${url.host}');
      return true;
    }

    return false;
  }

  static Future<List<String>> getOllamaModels(String ollamaHost) async {
    try {
      final uri = Uri.parse("$ollamaHost/api/tags");
      final headers = {
        "Accept": "application/json",
      };

      var request = http.Request("GET", uri)..headers.addAll(headers);

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var data = json.decode(responseString);

      List<String> newOptions = [];
      if (data['models'] != null) {
        for (var option in data['models']) {
          newOptions.add(option['name']);
        }
      }

      return newOptions;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}