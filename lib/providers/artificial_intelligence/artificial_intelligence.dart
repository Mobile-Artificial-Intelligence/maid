part of 'package:maid/main.dart';

class ArtificialIntelligenceProvider extends ChangeNotifier {
  ArtificialIntelligenceProvider() {
    load();
  }

  static ArtificialIntelligenceProvider of(BuildContext context, {bool listen = false}) => 
    Provider.of<ArtificialIntelligenceProvider>(context, listen: listen);

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

  ArtificialIntelligenceNotifier _aiNotifier = LlamaCppNotifier();

  ArtificialIntelligenceNotifier get aiNotifier => _aiNotifier;

  RemoteArtificialIntelligenceNotifier? get remoteAiNotifier => _aiNotifier is RemoteArtificialIntelligenceNotifier ? _aiNotifier as RemoteArtificialIntelligenceNotifier : null;

  LlamaCppNotifier? get llamaCppNotifier => _aiNotifier is LlamaCppNotifier ? _aiNotifier as LlamaCppNotifier : null;

  OllamaNotifier? get ollamaNotifier => _aiNotifier is OllamaNotifier ? _aiNotifier as OllamaNotifier : null;

  set aiNotifier(ArtificialIntelligenceNotifier newContext) {
    _aiNotifier = newContext;
    _aiNotifier.addListener(notify);
    saveAndNotify();
  }

  Future<void> switchAi(String type) async {
    await _aiNotifier.save();

    if (_aiNotifier.type == type) return;

    _aiNotifier = await ArtificialIntelligenceNotifier.load(type);
    _aiNotifier.addListener(notify);

    notifyListeners();
  }

  String? get model => _aiNotifier.model;

  set model(String? newModel) {
    _aiNotifier.model = newModel;
    saveAndNotify();
  }

  Map<String, dynamic> get overrides => _aiNotifier.overrides;

  set overrides(Map<String, dynamic> newOverrides) {
    _aiNotifier.overrides = newOverrides;
    saveAndNotify();
  }

  String? get baseUrl => remoteAiNotifier?.baseUrl;

  set baseUrl(String? newBaseUrl) {
    remoteAiNotifier?.baseUrl = newBaseUrl;
    saveAndNotify();
  }

  String? get apiKey => remoteAiNotifier?.apiKey;

  set apiKey(String? newApiKey) {
    remoteAiNotifier?.apiKey = newApiKey;
    saveAndNotify();
  }

  bool busy = false;
  
  bool get canPrompt {
    if (busy) return false;

    return _aiNotifier.canPrompt;
  }

  String getEcosystemHash() {
    return (remoteAiNotifier?.baseUrl?.hash ?? '') + (remoteAiNotifier?.apiKey?.hash ?? '');
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final aiType = prefs.getString('ai_type');

    if (aiType != null) {
      _aiNotifier = await ArtificialIntelligenceNotifier.load(aiType);
    }

    _aiNotifier.addListener(notify);

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

    await prefs.setString('ai_type', _aiNotifier.type);

    await _aiNotifier.save();

    List<String> chatsStrings = [];

    for (final chat in _chats) {
      final chatMap = chat.toMap(ChatMessage.messageToMap);
      final chatString = jsonEncode(chatMap);
      chatsStrings.add(chatString);
    }

    await prefs.setStringList('chats', chatsStrings);
  }
}