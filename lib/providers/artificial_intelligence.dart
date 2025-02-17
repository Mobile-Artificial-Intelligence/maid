part of 'package:maid/main.dart';

class ArtificialIntelligence extends ChangeNotifier {
  ArtificialIntelligence() {
    load();
  }

  static ArtificialIntelligence of(BuildContext context, {bool listen = false}) => 
    Provider.of<ArtificialIntelligence>(context, listen: listen);

  List<GeneralTreeNode<ChatMessage>> _chats = [];

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

  final Map<LlmEcosystem, String?> _model = {};

  Map<LlmEcosystem, String?> get model => _model;

  void setModel(LlmEcosystem ecosystem, String modelPath) {
    _model[ecosystem] = modelPath;
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

  bool busy = false;

  bool get llamaLoaded => _llama != null;
  bool get canPrompt => (
      (ecosystem == LlmEcosystem.llamaCPP && llamaLoaded) || 
      (ecosystem == LlmEcosystem.ollama && _model[LlmEcosystem.ollama] != null && _model[LlmEcosystem.ollama]!.isNotEmpty)
    ) && !busy;

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

    setModel(LlmEcosystem.llamaCPP, result.files.single.path!);

    final exists = await File(_model[LlmEcosystem.llamaCPP]!).exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    reloadModel();
  }

  void reloadModel() {
    if (_model[LlmEcosystem.llamaCPP] == null) return;

    _llama = LlamaIsolated(
      modelParams: ModelParams(
        path: _model[LlmEcosystem.llamaCPP]!,
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

  late OllamaClient _ollamaClient;

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
      final hostUri = Uri.parse('http://${host.internetAddress.address}:11434');
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
    assert(_model[LlmEcosystem.llamaCPP] != null);

    yield* _llama!.prompt(messages);
  }

  Stream<String> ollamaPrompt(List<ChatMessage> messages) async* {
    assert(_model[LlmEcosystem.ollama] != null);

    _ollamaClient = OllamaClient(baseUrl: "$ollamaUrl/api");

    final completionStream = _ollamaClient.generateChatCompletionStream(
      request: GenerateChatCompletionRequest(
        model: _model[LlmEcosystem.ollama]!, 
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
    switch (ecosystem) {
      case LlmEcosystem.llamaCPP:
        _llama?.stop();
        break;
      case LlmEcosystem.ollama:
        _ollamaClient.endSession();
        break;
      default:
        throw Exception('Invalid ecosystem');
    }


    await save();
    busy = false;
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final modelsString = prefs.getString('models');
    if (modelsString != null) {
      final modelsMap = jsonDecode(modelsString);
      
      for (final entry in modelsMap.entries) {
        _model[LlmEcosystem.values.firstWhere((e) => e.name == entry.key)] = entry.value;
      }
    }

    if (_model[LlmEcosystem.llamaCPP] != null) {
      _llama = LlamaIsolated(
        modelParams: ModelParams(path: _model[LlmEcosystem.llamaCPP]!),
        contextParams: const ContextParams(nCtx: 0),
        samplingParams: SamplingParams(
          greedy: true,
          seed: math.Random().nextInt(1000000)
        )
      );
    }

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

    Map<String, String> modelMap = {};
    for (final entry in _model.entries) {
      if (entry.value == null) continue;
      modelMap[entry.key.name] = entry.value!;
    }

    if (modelMap.isNotEmpty) {
      final modelString = jsonEncode(modelMap);
      prefs.setString('models', modelString);
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