part of 'package:maid/main.dart';

class ArtificialIntelligence extends ChangeNotifier {
  ArtificialIntelligence({
    this.model,
    List<GeneralTreeNode<ChatMessage>>? chats
  }) : chats = chats ?? [] {
    load();
  }

  static ArtificialIntelligence of(BuildContext context, {bool listen = false}) => 
    Provider.of<ArtificialIntelligence>(context, listen: listen);

  List<GeneralTreeNode<ChatMessage>> chats;

  GeneralTreeNode<ChatMessage> get root => chats.isNotEmpty ? 
    chats.first : GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));

  set root(GeneralTreeNode<ChatMessage> newRoot){
    chats.remove(newRoot);

    chats.insert(0, newRoot);

    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final modelPath = prefs.getString('model');
    if (modelPath != null) {
      model = File(modelPath);
      notifyListeners();
    }

    if (model != null) {
      llama = LlamaIsolated(
        modelParams: ModelParams(path: model!.path),
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

    chats.clear();
    for (final chatString in chatsStrings) {
      final chatMap = jsonDecode(chatString);
      final chat = GeneralTreeNode.fromMap(chatMap, ChatMessage.fromMap);
      chats.add(chat);
      notifyListeners();
    }

    if (chats.isEmpty) {
      final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));
      chats.add(chat);
      notifyListeners();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    if (model != null) {
      prefs.setString('model', model!.path);
    }

    if (overrides.isNotEmpty) {
      final overridesString = jsonEncode(overrides);
      prefs.setString('overrides', overridesString);
    }

    List<String> chatsStrings = [];

    for (final chat in chats) {
      final chatMap = chat.toMap(ChatMessage.messageToMap);
      final chatString = jsonEncode(chatMap);
      chatsStrings.add(chatString);
    }

    prefs.setStringList('chats', chatsStrings);
  }

  void newChat() {
    final chat = GeneralTreeNode<ChatMessage>(SystemChatMessage('New Chat'));

    chats.insert(0, chat);
    
    notifyListeners();
  }

  void clearChats() {
    chats.clear();
    save();
    notifyListeners();
  }

  File? model;
  Llama? llama;

  bool busy = false;

  bool get llamaLoaded => llama != null;
  bool get canPrompt => llamaLoaded && !busy;

  LlmEcosystem _ecosystem = LlmEcosystem.llama;

  LlmEcosystem get ecosystem => _ecosystem;

  set ecosystem(LlmEcosystem newEcosystem) {
    _ecosystem = newEcosystem;
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

    model = File(result.files.single.path!);

    final exists = await model!.exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    reloadModel();
  }

  void reloadModel() {
    if (model == null) return;

    llama = LlamaIsolated(
      modelParams: ModelParams(
        path: model!.path,
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

  void prompt(String message) async {
    assert(llama != null);

    root.chain.last.addChild(UserChatMessage(message));

    busy = true;
    notifyListeners();

    Stream<String> stream = llama!.prompt(root.chainData.copy());

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

    final chainData = node.chainData.copy();
    if (chainData.last is AssistantChatMessage) {
      chainData.removeLast();
    }

    final stream = llama!.prompt(chainData);

    node.addChild(AssistantChatMessage(''));
    notifyListeners();

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