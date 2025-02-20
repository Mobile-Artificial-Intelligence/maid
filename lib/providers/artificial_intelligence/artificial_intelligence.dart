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

  ArtificialIntelligenceEcosystem _ecosystem = ArtificialIntelligenceEcosystem.llamaCPP;

  ArtificialIntelligenceEcosystem get ecosystem => _ecosystem;

  set ecosystem(ArtificialIntelligenceEcosystem eco) {
    final oldEco = _ecosystem;
    _ecosystem = eco;
    switchContext(oldEco);
    saveAndNotify();
  }

  ArtificialIntelligenceContext _context = ArtificialIntelligenceContext();

  ArtificialIntelligenceContext get context => _context;

  RemoteArtificialIntelligenceContext? get remoteContext => _context is RemoteArtificialIntelligenceContext ? _context as RemoteArtificialIntelligenceContext : null;

  set context(ArtificialIntelligenceContext newContext) {
    _context = newContext;
    saveAndNotify();
  }

  Future<void> switchContext(ArtificialIntelligenceEcosystem oldEco) async {
    if (oldEco == _ecosystem) return;

    await _context.save(oldEco);

    if (_ecosystem == ArtificialIntelligenceEcosystem.llamaCPP) {
      _context = await ArtificialIntelligenceContext.load(_ecosystem) ?? ArtificialIntelligenceContext();
    }
    else {
      _context = await RemoteArtificialIntelligenceContext.load(_ecosystem) ?? RemoteArtificialIntelligenceContext();
    }

    notifyListeners();
  }

  String? get model => _context.model;

  set model(String? newModel) {
    _context.model = newModel;
    saveAndNotify();
  }

  Map<String, dynamic> get overrides => _context.overrides;

  set overrides(Map<String, dynamic> newOverrides) {
    _context.overrides = newOverrides;
    saveAndNotify();
  }

  String? get baseUrl => remoteContext?.baseUrl;

  set baseUrl(String? newBaseUrl) {
    remoteContext?.baseUrl = newBaseUrl;
    saveAndNotify();
  }

  String? get apiKey => remoteContext?.apiKey;

  set apiKey(String? newApiKey) {
    remoteContext?.apiKey = newApiKey;
    saveAndNotify();
  }

  Llama? _llama;

  bool busy = false;
  
  bool get canPrompt {
    if (busy) return false;

    if (
      ecosystem == ArtificialIntelligenceEcosystem.llamaCPP && 
      _llama != null
    ) {
      return true;
    }
    else if (
      ecosystem == ArtificialIntelligenceEcosystem.ollama && 
      context.model != null && context.model!.isNotEmpty
    ) {
      return true;
    }
    else if (
      remoteContext?.apiKey != null && 
      remoteContext!.apiKey!.isNotEmpty &&
      context.model != null && 
      context.model!.isNotEmpty
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

  String getEcosystemHash() {
    return (remoteContext?.baseUrl?.hash ?? '') + (remoteContext?.apiKey?.hash ?? '');
  }

  Future<List<String>> getModelOptions() async {
    switch (ecosystem) {
      case ArtificialIntelligenceEcosystem.llamaCPP:
        return ['null'];
      case ArtificialIntelligenceEcosystem.ollama:
        return getOllamaModelOptions();
      case ArtificialIntelligenceEcosystem.openAI:
        return getOpenAiModelOptions();
      case ArtificialIntelligenceEcosystem.mistral:
        return getMistralModelOptions();
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final ecosystemString = prefs.getString('ecosystem');
    if (ecosystemString != null) {
      _ecosystem = ArtificialIntelligenceEcosystem.values.firstWhere((e) => e.name == ecosystemString);
    }

    if (_ecosystem == ArtificialIntelligenceEcosystem.llamaCPP) {
      _context = await ArtificialIntelligenceContext.load(_ecosystem) ?? ArtificialIntelligenceContext();
    }
    else {
      _context = await RemoteArtificialIntelligenceContext.load(_ecosystem) ?? RemoteArtificialIntelligenceContext();
    }

    if (_context.model != null) {
      _llama = LlamaIsolated(
        modelParams: ModelParams(
          path: model!,
          vocabOnly: overrides['vocab_only'],
          useMmap: overrides['use_mmap'],
          useMlock: overrides['use_mlock'],
          checkTensors: overrides['check_tensors']
        ),
        contextParams: ContextParams.fromMap(overrides),
        samplingParams: SamplingParams(
          greedy: true,
          seed: math.Random().nextInt(1000000)
        )
      );
    }

    _searchLocalNetworkForOllama = prefs.getBool('search_local_network_for_ollama');

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

    await prefs.setString('ecosystem', _ecosystem.name);

    await _context.save(_ecosystem);

    if (_searchLocalNetworkForOllama != null) {
      await prefs.setBool('search_local_network_for_ollama', _searchLocalNetworkForOllama!);
    }

    List<String> chatsStrings = [];

    for (final chat in _chats) {
      final chatMap = chat.toMap(ChatMessage.messageToMap);
      final chatString = jsonEncode(chatMap);
      chatsStrings.add(chatString);
    }

    await prefs.setStringList('chats', chatsStrings);
  }
}