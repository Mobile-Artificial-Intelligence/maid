part of 'package:maid/main.dart';

class ArtificialIntelligence extends ChangeNotifier {
  ArtificialIntelligence() {
    load();
  }

  static ArtificialIntelligence of(BuildContext context, {bool listen = false}) => 
    Provider.of<ArtificialIntelligence>(context, listen: listen);

  void notify() {
    notifyListeners();
  }

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
    
    save();
    notifyListeners();
  }

  void deleteChat(GeneralTreeNode<ChatMessage> chat) {
    _chats.remove(chat);
    save();
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
  
  bool get canPrompt {
    if (busy) return false;

    if (
      ecosystem == LlmEcosystem.llamaCPP && 
      _llama != null
    ) {
      return true;
    }
    else if (
      ecosystem == LlmEcosystem.ollama && 
      _model[LlmEcosystem.ollama] != null && 
      _model[LlmEcosystem.ollama]!.isNotEmpty
    ) {
      return true;
    }

    return false;
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