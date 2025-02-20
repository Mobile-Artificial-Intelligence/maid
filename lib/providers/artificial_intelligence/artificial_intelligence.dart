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

  void saveAndNotify() {
    save();
    notifyListeners();
  }

  List<GeneralTreeNode<ChatMessage>> _chats = [];

  List<GeneralTreeNode<ChatMessage>> get chats => _chats;

  set chats(List<GeneralTreeNode<ChatMessage>> newChats) {
    _chats = newChats;
    notifyListeners();
  }

  LlmEcosystem _ecosystem = LlmEcosystem.llamaCPP;

  LlmEcosystem get ecosystem => _ecosystem;

  set ecosystem(LlmEcosystem eco) {
    _ecosystem = eco;
    saveAndNotify();
  }

  final Map<LlmEcosystem, String?> model = {};

  void setModel(LlmEcosystem eco, String modelPath) {
    model[eco] = modelPath;
    saveAndNotify();
  }

  final Map<LlmEcosystem, String?> baseUrl = {};

  void setBaseUrl(LlmEcosystem eco, String? url) {
    baseUrl[eco] = url;
    saveAndNotify();
  }

  final Map<LlmEcosystem, String?> apiKey = {};

  void setApiKey(LlmEcosystem eco, String? key) {
    apiKey[eco] = key;
    saveAndNotify();
  }

  Map<String, dynamic> _overrides = {};

  Map<String, dynamic> get overrides => _overrides;

  set overrides(Map<String, dynamic> value) {
    _overrides = value;
    saveAndNotify();
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
      model[LlmEcosystem.ollama] != null && 
      model[LlmEcosystem.ollama]!.isNotEmpty
    ) {
      return true;
    }
    else if (
      ecosystem == LlmEcosystem.openAI && 
      apiKey[LlmEcosystem.openAI] != null && 
      apiKey[LlmEcosystem.openAI]!.isNotEmpty &&
      model[LlmEcosystem.openAI] != null && 
      model[LlmEcosystem.openAI]!.isNotEmpty
    ) {
      return true;
    }

    return false;
  }

  late mistral.MistralAIClient _mistralClient;

  late open_ai.OpenAIClient _openAiClient;

  late ollama.OllamaClient _ollamaClient;

  bool? _searchLocalNetworkForOllama;

  bool? get searchLocalNetworkForOllama => _searchLocalNetworkForOllama;

  set searchLocalNetworkForOllama(bool? value) {
    _searchLocalNetworkForOllama = value;
    saveAndNotify();
  }

  String getEcosystemHash(LlmEcosystem eco) {
    return (baseUrl[eco]?.hash ?? '') + (apiKey[eco]?.hash ?? '');
  }

  Future<List<String>> getModelOptions(LlmEcosystem eco) async {
    switch (eco) {
      case LlmEcosystem.llamaCPP:
        return ['null'];
      case LlmEcosystem.ollama:
        return getOllamaModelOptions();
      case LlmEcosystem.openAI:
        return getOpenAiModelOptions();
      case LlmEcosystem.mistral:
        return getMistralModelOptions();
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final ecosystemString = prefs.getString('ecosystem');
    if (ecosystemString != null) {
      _ecosystem = LlmEcosystem.values.firstWhere((e) => e.name == ecosystemString);
    }

    final modelsString = prefs.getString('models');
    if (modelsString != null) {
      final modelsMap = jsonDecode(modelsString);
      
      for (final entry in modelsMap.entries) {
        model[LlmEcosystem.values.firstWhere((e) => e.name == entry.key)] = entry.value;
      }
    }

    final baseUrlsString = prefs.getString('base_urls');
    if (baseUrlsString != null) {
      final baseUrlsMap = jsonDecode(baseUrlsString);
      
      for (final entry in baseUrlsMap.entries) {
        baseUrl[LlmEcosystem.values.firstWhere((e) => e.name == entry.key)] = entry.value;
      }
    }

    final apiKeysString = prefs.getString('api_keys');
    if (apiKeysString != null) {
      final apiKeysMap = jsonDecode(apiKeysString);
      
      for (final entry in apiKeysMap.entries) {
        apiKey[LlmEcosystem.values.firstWhere((e) => e.name == entry.key)] = entry.value;
      }
    }

    if (model[LlmEcosystem.llamaCPP] != null) {
      _llama = LlamaIsolated(
        modelParams: ModelParams(path: model[LlmEcosystem.llamaCPP]!),
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

    prefs.setString('ecosystem', _ecosystem.name);

    Map<String, String> modelMap = {};
    for (final entry in model.entries) {
      if (entry.value == null) continue;
      modelMap[entry.key.name] = entry.value!;
    }

    if (modelMap.isNotEmpty) {
      final modelString = jsonEncode(modelMap);
      prefs.setString('models', modelString);
    }

    Map<String, String> baseUrlMap = {};
    for (final entry in baseUrl.entries) {
      if (entry.value == null) continue;
      baseUrlMap[entry.key.name] = entry.value!;
    }

    if (baseUrlMap.isNotEmpty) {
      final baseUrlString = jsonEncode(baseUrlMap);
      prefs.setString('base_urls', baseUrlString);
    }

    Map<String, String> apiKeyMap = {};
    for (final entry in apiKey.entries) {
      if (entry.value == null) continue;
      apiKeyMap[entry.key.name] = entry.value!;
    }

    if (apiKeyMap.isNotEmpty) {
      final apiKeyString = jsonEncode(apiKeyMap);
      prefs.setString('api_keys', apiKeyString);
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