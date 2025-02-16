part of 'package:maid/main.dart';

class ArtificialIntelligence extends ChangeNotifier {
  ArtificialIntelligence({
    String? model,
    List<GeneralTreeNode<ChatMessage>>? chats
  }) : _llamaModel = model, _chats = chats ?? [] {
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

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _llamaModel = prefs.getString('model');
    notifyListeners();

    if (_llamaModel != null) {
      llama = LlamaIsolated(
        modelParams: ModelParams(path: _llamaModel!),
        contextParams: const ContextParams(nCtx: 0),
        samplingParams: SamplingParams(
          greedy: true,
          seed: math.Random().nextInt(1000000)
        )
      );
      notifyListeners();
    }

    final overridesString = prefs.getString('overrides');
    if (overridesString != null) {
      overrides = jsonDecode(overridesString);
      notifyListeners();
    }

    final chatsStrings = prefs.getStringList('chats') ?? [];

    _chats.clear();
    for (final chatString in chatsStrings) {
      final chatMap = jsonDecode(chatString);
      final chat = GeneralTreeNode.fromMap(chatMap, ChatMessage.fromMap);
      _chats.add(chat);
      notifyListeners();
    }

    if (_chats.isEmpty) {
      final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));
      _chats.add(chat);
      notifyListeners();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    if (_llamaModel != null) {
      prefs.setString('model', _llamaModel!);
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

  String? _llamaModel;

  String? get llamaModel => _llamaModel;

  set llamaModel(String? newModel) {
    _llamaModel = newModel;
    save();
    notifyListeners();
  }

  Llama? llama;
  OllamaClient ollama = OllamaClient();

  bool busy = false;

  bool get llamaLoaded => llama != null;
  bool get canPrompt => llamaLoaded && !busy;

  String? _url;

  String get url => _url ?? 'http://localhost:11434';

  set url(String newUrl) {
    _url = newUrl;
    save();
    notifyListeners();
  }

  LlmEcosystem _ecosystem = LlmEcosystem.llama;

  LlmEcosystem get ecosystem => _ecosystem;

  set ecosystem(LlmEcosystem newEcosystem) {
    _ecosystem = newEcosystem;
    save();
    notifyListeners();
  }

  Map<String, dynamic> _overrides = {};

  Map<String, dynamic> get overrides => _overrides;

  set overrides(Map<String, dynamic> newOverrides) {
    _overrides = newOverrides;
    reloadModel();
    notifyListeners();
  }

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

    _llamaModel = result.files.single.path!;

    final exists = await File(_llamaModel!).exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    reloadModel();
  }

  void reloadModel() {
    if (_llamaModel == null) return;

    llama = LlamaIsolated(
      modelParams: ModelParams(
        path: _llamaModel!,
        vocabOnly: overrides['vocab_only'],
        useMmap: overrides['use_mmap'],
        useMlock: overrides['use_mlock'],
        checkTensors: overrides['check_tensors']
      ),
      contextParams: ContextParams.fromMap(overrides),
      samplingParams: SamplingParams.fromMap({...overrides, 'greedy': true, 'seed': math.Random().nextInt(1000000)})
    );
    notifyListeners();
  }

  Future<List<String>> getOllamaModels() async {
    try {
      final uri = Uri.parse("$url/api/tags");
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

  Stream<String> ollamaPrompt(List<ChatMessage> messages) async* {
    assert(_llamaModel != null);

    final client = OllamaClient(baseUrl: url);

    final completionStream = client.generateChatCompletionStream(
      request: GenerateChatCompletionRequest(
        model: _llamaModel!, 
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
      case LlmEcosystem.llama:
        yield* llama!.prompt(messages);
        break;
      case LlmEcosystem.ollama:
        yield* ollamaPrompt(messages);
        break;
      default:
        throw Exception('Invalid ecosystem');
    }
  }

  void prompt(String message) async {
    assert(llama != null);
    assert(_llamaModel != null);

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

    llama!.reload();
    assert(llama != null);

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
    llama?.stop();
    await save();
    busy = false;
    notifyListeners();
  }
}