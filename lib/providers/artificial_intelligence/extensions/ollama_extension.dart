part of 'package:maid/main.dart';

extension OllamaExtension on ArtificialIntelligence {
  Stream<String> ollamaPrompt(List<ChatMessage> messages) async* {
    assert(remoteContext != null);
    assert(model != null);

    _ollamaClient = ollama.OllamaClient(
      baseUrl: "${baseUrl ?? 'http://localhost:11434'}/api",
      headers: {
        'Authorization': 'Bearer $apiKey'
      }
    );

    final completionStream = _ollamaClient.generateChatCompletionStream(
      request: ollama.GenerateChatCompletionRequest(
        model: model!, 
        messages: messages.toOllamaMessages(),
        options: ollama.RequestOptions.fromJson(overrides),
        stream: true
      )
    );

    try {
      await for (final completion in completionStream) {
        yield completion.message.content;
      }
    }
    catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    }
  }
  
  Future<Uri?> checkForOllama(Uri url) async {
    try {
      final request = http.Request("GET", url);
      final headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $apiKey'
      };

      request.headers.addAll(headers);

      final response = await request.send();
      if (response.statusCode == 200) {
        log('Found Ollama at ${url.host}');
        return url;
      }
    } catch (e) {
      if (!e.toString().contains(RegExp(r'Connection (failed|refused)'))) {
        log(e.toString());
      }
    }

    return null;
  }

  Future<bool> searchForOllama() async {
    assert(remoteContext != null);
    assert(_searchLocalNetworkForOllama == true);

    // Check current URL
    if (baseUrl != null && await checkForOllama(Uri.parse(baseUrl!)) != null) {
      return true;
    }

    // Check localhost
    if (await checkForOllama(Uri.parse('http://localhost:11434')) != null) {
      remoteContext!.baseUrl = 'http://localhost:11434';
      save();
      return true;
    }

    final localIP = await NetworkInfo().getWifiIP();

    // Get the first 3 octets of the local IP
    final baseIP = ipToCSubnet(localIP ?? '');

    // Scan the local network for hosts
    final hosts = await LanScanner(debugLogging: true).quickIcmpScanAsync(baseIP);

    List<Future<Uri?>> hostFutures = [];
    for (final host in hosts) {
      final hostUri = Uri.parse('http://${host.internetAddress.address}:11434');
      hostFutures.add(checkForOllama(hostUri));
    }

    final results = await Future.wait(hostFutures);

    final validUrls = results.where((result) => result != null);

    if (validUrls.isNotEmpty) {
      remoteContext!.baseUrl = validUrls.first.toString();
      return true;
    }
    return false;
  }

  Future<List<String>> getOllamaModelOptions() async {
    try {
      if (searchLocalNetworkForOllama == true) {
        final found = await searchForOllama();
        if (!found) return [];
      }
  
      final uri = Uri.parse("${baseUrl ?? 'http://localhost:11434'}/api/tags");
  
      final request = http.Request("GET", uri);
  
      final headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $apiKey'
      };
  
      request.headers.addAll(headers);

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final data = json.decode(responseString);

      List<String> newOptions = [];
      if (data['models'] != null) {
        for (final option in data['models']) {
          newOptions.add(option['name']);
        }
      }

      return newOptions;
    }
    catch (e) {
      if (!e.toString().contains(RegExp(r'Connection (failed|refused)'))) {
        rethrow;
      }
      return [];
    }
  }
}