part of 'package:maid/main.dart';

class ArtificialIntelligence extends ChangeNotifier {
  ArtificialIntelligence({
    String? model,
    List<GeneralTreeNode<ChatMessage>>? chats
  }) : _llamaCppModel = model, _chats = chats ?? [] {
    load();
  }

  static ArtificialIntelligence of(BuildContext context, {bool listen = false}) => 
    Provider.of<ArtificialIntelligence>(context, listen: listen);

  List<GeneralTreeNode<ChatMessage>> _chats;

  List<GeneralTreeNode<ChatMessage>> get chats => _chats;

  set chats(List<GeneralTreeNode<ChatMessage>> newChats) {
    _chats = newChats;
    notifyListeners();
  }

  GeneralTreeNode<ChatMessage> get root => _chats.isNotEmpty ? 
    _chats.first : GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));

  set root(GeneralTreeNode<ChatMessage> newRoot){
    _chats.remove(newRoot);

    _chats.insert(0, newRoot);

    notifyListeners();
  }

  void newChat() {
    final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));

    _chats.insert(0, chat);
    
    notifyListeners();
  }

  void clearChats() {
    _chats.clear();
    save();
    notifyListeners();
  }

  LlmEcosystem _ecosystem = LlmEcosystem.llamaCPP;

  LlmEcosystem get ecosystem => _ecosystem;

  set ecosystem(LlmEcosystem newEcosystem) {
    _ecosystem = newEcosystem;
    save();
    notifyListeners();
  }

  Map<String, dynamic> _overrides = {};

  Map<String, dynamic> get overrides => _overrides;

  set overrides(Map<String, dynamic> value) {
    _overrides = value;
    reloadModel();
    notifyListeners();
  }

  Llama? _llama;

  String? _llamaCppModel;

  String? get llamaCppModel => _llamaCppModel;

  set llamaCppModel(String? value) {
    _llamaCppModel = value;
    save();
    notifyListeners();
  }

  bool busy = false;

  bool get llamaLoaded => _llama != null;
  bool get canPrompt => llamaLoaded && !busy;

  void loadModel() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      throw Exception('No file selected');
    }

    _llamaCppModel = result.files.single.path!;

    final exists = await File(_llamaCppModel!).exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    reloadModel();
  }

  void reloadModel() {
    if (_llamaCppModel == null) return;

    _llama = LlamaIsolated(
      modelParams: ModelParams(
        path: _llamaCppModel!,
        vocabOnly: overrides['vocab_only'],
        useMmap: overrides['use_mmap'],
        useMlock: overrides['use_mlock'],
        checkTensors: overrides['check_tensors']
      ),
      contextParams: ContextParams.fromMap(overrides),
      samplingParams: SamplingParams.fromMap({...overrides, 'greedy': true, 'seed': math.Random().nextInt(1000000)})
    );
    save();
    notifyListeners();
  }

  String? _ollamaModel;

  String? get ollamaModel => _ollamaModel;

  set ollamaModel(String? value) {
    _ollamaModel = value;
    save();
    notifyListeners();
  }

  String? _ollamaUrl;

  String get ollamaUrl => _ollamaUrl ?? 'http://localhost:11434';

  set ollamaUrl(String value) {
    _ollamaUrl = value;
    save();
    notifyListeners();
  }

  bool? _searchLocalNetworkForOllama;

  bool? get searchLocalNetworkForOllama => _searchLocalNetworkForOllama;

  set searchLocalNetworkForOllama(bool? value) {
    _searchLocalNetworkForOllama = value;
    notifyListeners();
  }

  Future<Uri?> checkForOllama(Uri url) async {
    try {
      final request = http.Request("GET", url);
      final headers = {
        "Accept": "application/json",
      };

      request.headers.addAll(headers);

      final response = await request.send();
      if (response.statusCode == 200) {
        log('Found Ollama at ${url.host}');
        return url;
      }
    } catch (e) {
      log(e.toString());
    }

    return null;
  }

  Future<bool> searchForOllama() async {
    assert(_searchLocalNetworkForOllama == true);

    // Check current URL and localhost first
    if (await checkForOllama(Uri.parse(ollamaUrl)) != null) {
      return true;
    }

    final localIP = await NetworkInfo().getWifiIP();

    // Get the first 3 octets of the local IP
    final baseIP = ipToCSubnet(localIP ?? '');

    // Scan the local network for hosts
    final hosts = await LanScanner(debugLogging: true).quickIcmpScanAsync(baseIP);

    List<Future<Uri?>> hostFutures = [];
    for (final host in hosts) {
      final hostUri = Uri.parse('http://$host:11434');
      hostFutures.add(checkForOllama(hostUri));
    }

    final results = await Future.wait(hostFutures);

    final validUrls = results.where((result) => result != null);

    if (validUrls.isNotEmpty) {
      _ollamaUrl = validUrls.first.toString();
      await save();
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<List<String>> getOllamaModelOptions() async {
    try {
      if (searchLocalNetworkForOllama == true) {
        final found = await searchForOllama();
        if (!found) return [];
      }

      final uri = Uri.parse("$ollamaUrl/api/tags");
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

  Stream<String> llamaPrompt(List<ChatMessage> messages) async* {
    assert(_llama != null);
    assert(_llamaCppModel != null);

    yield* _llama!.prompt(messages);
  }

  Stream<String> ollamaPrompt(List<ChatMessage> messages) async* {
    assert(_ollamaModel != null);

    final client = OllamaClient(baseUrl: ollamaUrl);

    final completionStream = client.generateChatCompletionStream(
      request: GenerateChatCompletionRequest(
        model: _ollamaModel!, 
        messages: messages.toOllamaMessages(),
        options: RequestOptions.fromJson(overrides),
        stream: true
      )
    );

    await for (final completion in completionStream) {
      yield completion.message.content;
    }
  }

  Stream<String> ecosystemPrompt(List<ChatMessage> messages) async* {
    switch (ecosystem) {
      case LlmEcosystem.llamaCPP:
        yield* llamaPrompt(messages);
        break;
      case LlmEcosystem.ollama:
        yield* ollamaPrompt(messages);
        break;
      default:
        throw Exception('Invalid ecosystem');
    }
  }

  void prompt(String message) async {
    root.chain.last.addChild(UserChatMessage(message));

    busy = true;
    notifyListeners();

    Stream<String> stream = ecosystemPrompt(root.chainData.copy());

    root.chain.last.addChild(AssistantChatMessage(''));
    notifyListeners();

    await for (final response in stream) {
      root.chain.last.data.content += response;
      notifyListeners();
    }

    await save();

    busy = false;
    notifyListeners();
  }

  void regenerate(GeneralTreeNode<ChatMessage> node) async {
    busy = true;
    notifyListeners();

    if (_ecosystem == LlmEcosystem.llamaCPP) {
      reloadModel();
      assert(_llama != null);
    }

    final chainData = root.chainData.copy();
    if (chainData.last is AssistantChatMessage) {
      chainData.removeLast();
    }

    final stream = ecosystemPrompt(chainData);

    assert(node.currentChild == root.chain.last);

    await for (final response in stream) {
      root.chain.last.data.content += response;
      notifyListeners();
    }

    await save();

    busy = false;
    notifyListeners();
  }

  void stop() async {
    _llama?.stop();
    await save();
    busy = false;
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _llamaCppModel = prefs.getString('llama_model');

    if (_llamaCppModel != null) {
      _llama = LlamaIsolated(
        modelParams: ModelParams(path: _llamaCppModel!),
        contextParams: const ContextParams(nCtx: 0),
        samplingParams: SamplingParams(
          greedy: true,
          seed: math.Random().nextInt(1000000)
        )
      );
    }

    _ollamaModel = prefs.getString('ollama_model');
    _searchLocalNetworkForOllama = prefs.getBool('search_local_network_for_ollama');

    final overridesString = prefs.getString('overrides');
    if (overridesString != null) {
      overrides = jsonDecode(overridesString);
    }

    final chatsStrings = prefs.getStringList('chats') ?? [];

    _chats.clear();
    for (final chatString in chatsStrings) {
      final chatMap = jsonDecode(chatString);
      final chat = GeneralTreeNode.fromMap(chatMap, ChatMessage.fromMap);
      _chats.add(chat);
    }

    if (_chats.isEmpty) {
      final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));
      _chats.add(chat);
    }

    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    if (_llamaCppModel != null) {
      prefs.setString('llama_model', _llamaCppModel!);
    }

    if (_ollamaModel != null) {
      prefs.setString('ollama_model', _ollamaModel!);
    }

    if (_searchLocalNetworkForOllama != null) {
      prefs.setBool('search_local_network_for_ollama', _searchLocalNetworkForOllama!);
    }

    if (overrides.isNotEmpty) {
      final overridesString = jsonEncode(overrides);
      prefs.setString('overrides', overridesString);
    }

    List<String> chatsStrings = [];

    for (final chat in _chats) {
      final chatMap = chat.toMap(ChatMessage.messageToMap);
      final chatString = jsonEncode(chatMap);
      chatsStrings.add(chatString);
    }

    prefs.setStringList('chats', chatsStrings);
  }
}