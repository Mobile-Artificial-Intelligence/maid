part of 'package:maid/main.dart';

abstract class ArtificialIntelligenceController extends ChangeNotifier {
  static Map<String, String> getTypes(BuildContext context) => {
    'llama_cpp': AppLocalizations.of(context)!.llamaCpp,
    'ollama': AppLocalizations.of(context)!.ollama,
    'open_ai': AppLocalizations.of(context)!.openAI,
    'mistral': AppLocalizations.of(context)!.mistral,
  };

  bool _busy = false;

  bool get busy => _busy;

  set busy(bool newBusy) {
    _busy = newBusy;
    save();
    notifyListeners();
  }

  String? _model;

  String? get model => _model;

  set model(String? newModel) {
    _model = newModel;
    save();
    notifyListeners();
  }

  Map<String, dynamic> _overrides;

  Map<String, dynamic> get overrides => _overrides;

  set overrides(Map<String, dynamic> newOverrides) {
    _overrides = newOverrides;
    save();
    notifyListeners();
  }

  String get type;
  bool get canPrompt;
  String get hash => jsonEncode(toMap()).hash;

  ArtificialIntelligenceController({
    String? model, 
    Map<String, dynamic>? overrides
  }) : _model = model , _overrides = overrides ?? {};

  Map<String, dynamic> toMap() => {
    'model': _model,
    'overrides': _overrides,
  };

  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _overrides = map['overrides'] ?? {};
    save();
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('ai_type', type);

    final contextString = jsonEncode(toMap());

    await prefs.setString(type, contextString);
  }

  static Future<ArtificialIntelligenceController> load([String? type]) async {
    final prefs = await SharedPreferences.getInstance();

    type ??= prefs.getString('ai_type') ?? 'llama_cpp';

    final contextString = prefs.getString(type);

    final contextMap = jsonDecode(contextString ?? '{}');

    switch (type) {
      case 'llama_cpp':
        return LlamaCppController()
          ..fromMap(contextMap);
      case 'ollama':
        return OllamaController()
          ..fromMap(contextMap);
      case 'open_ai':
        return OpenAIController()
          ..fromMap(contextMap);
      case 'mistral':
        return MistralController()
          ..fromMap(contextMap);
      default:
        return LlamaCppController();
    }
  }

  Stream<String> prompt(List<ChatMessage> messages);

  void stop();

  void clear() async {
    _model = null;
    _overrides = {};
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(type);
    await prefs.remove('ai_type');
  }

  String getTypeLocale(BuildContext context);

  void notify() => notifyListeners();
}

abstract class RemoteArtificialIntelligenceController extends ArtificialIntelligenceController {
  static List<String> get types => [
    'ollama',
    'open_ai',
    'mistral',
  ];

  String? _baseUrl;

  String? get baseUrl => _baseUrl;

  set baseUrl(String? newBaseUrl) {
    _baseUrl = newBaseUrl;
    save();
    notifyListeners();
  }

  String? _apiKey;

  String? get apiKey => _apiKey;

  set apiKey(String? newApiKey) {
    _apiKey = newApiKey;
    save();
    notifyListeners();
  }

  String get connectionHash => (_baseUrl ?? '').hash + (_apiKey ?? '').hash;

  bool get canGetRemoteModels;

  List<String> _modelOptions = [];

  List<String> get modelOptions => _modelOptions;

  RemoteArtificialIntelligenceController({
    super.model, 
    super.overrides,
    String? baseUrl, 
    String? apiKey
  }) : _baseUrl = baseUrl, _apiKey = apiKey;

  @override
  Map<String, dynamic> toMap() => {
    'model': _model,
    'overrides': _overrides,
    'base_url': _baseUrl,
    'api_key': _apiKey,
  };

  @override
  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _overrides = map['overrides'] ?? {};
    _baseUrl = map['base_url'];
    _apiKey = map['api_key'];
    save();
    notifyListeners();
  }

  Future<bool> getModelOptions();

  @override
  void clear() async {
    _model = null;
    _overrides = {};
    _baseUrl = null;
    _apiKey = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(type);
    await prefs.remove('ai_type');
  }
}

class LlamaCppController extends ArtificialIntelligenceController {
  LlamaIsolated? _llama;
  String _loadedHash = '';

  bool loading = false;

  @override
  String get type => 'llama_cpp';

  @override
  bool get canPrompt => _llama != null && !busy;

  LlamaCppController({
    super.model, 
    super.overrides
  });

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_model != null);
    busy = true;

    reloadModel();
    assert(_llama != null);

    yield* _llama!.prompt(messages);
    busy = false;
  }

  void reloadModel([bool force = false]) async {
    if ((hash == _loadedHash && !force) || _model == null) return;

    _llama = LlamaIsolated(
      LlamaParams.fromMap({
        'model_path': _model,
        'seed': math.Random().nextInt(1000000),
        'greedy': true,
        ..._overrides
      })
    );

    _loadedHash = hash;
  }

  void pickModel() async {
    _model = null;
    
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false,
      onFileLoading: (status) {
        loading = status == FilePickerStatus.picking;
        super.notifyListeners();
      } 
    );

    loading = false;
    super.notifyListeners();

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      throw Exception('No file selected');
    }

    _model = result.files.single.path!;

    final exists = await File(_model!).exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    notifyListeners();
  }

  void loadModelFile(String path) async {
    assert (RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _model = path;
    reloadModel();
  }

  @override
  void stop() {
    _llama?.stop();
    busy = false;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    reloadModel();
    save();
  }

  @override
  void clear() {
    super.clear();
    _llama = null;
    _loadedHash = '';
    loading = false;
  }
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.llamaCpp;
}

class OllamaController extends RemoteArtificialIntelligenceController {
  late ollama.OllamaClient _ollamaClient;

  bool? _searchLocalNetwork;

  bool? get searchLocalNetwork => _searchLocalNetwork;

  set searchLocalNetwork(bool? value) {
    _searchLocalNetwork = value;
    save();
    notifyListeners();
  }

  @override
  String get type => 'ollama';

  @override
  bool get canPrompt => _model != null && _model!.isNotEmpty && !busy;

  OllamaController({
    super.model, 
    super.overrides,
    super.baseUrl, 
    super.apiKey
  });

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_model != null);
    busy = true;

    _ollamaClient = ollama.OllamaClient(
      baseUrl: "${_baseUrl ?? 'http://localhost:11434'}/api",
      headers: {
        'Authorization': 'Bearer $_apiKey'
      }
    );

    final completionStream = _ollamaClient.generateChatCompletionStream(
      request: ollama.GenerateChatCompletionRequest(
        model: _model!, 
        messages: messages.toOllamaMessages(),
        options: ollama.RequestOptions.fromJson(_overrides),
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
    finally {
      busy = false;
    }
  }

  @override
  void stop() {
    _ollamaClient.endSession();
    busy = false;
  }

  @override
  void clear() {
    super.clear();
    _searchLocalNetwork = null;
  }

  Future<Uri?> checkForOllama(Uri url) async {
    try {
      final request = http.Request("GET", url);
      final headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $_apiKey'
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
    assert(_searchLocalNetwork == true);

    // Check current URL
    if (_baseUrl != null && await checkForOllama(Uri.parse(_baseUrl!)) != null) {
      return true;
    }

    // Check localhost
    if (await checkForOllama(Uri.parse('http://localhost:11434')) != null) {
      _baseUrl = 'http://localhost:11434';
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
      _baseUrl = validUrls.first.toString();
      save();
      return true;
    }
    return false;
  }

  @override
  Future<bool> getModelOptions() async {
    try {
      if (searchLocalNetwork == true) {
        final found = await searchForOllama();
        if (!found) return false;
      }
  
      final uri = Uri.parse("${_baseUrl ?? 'http://localhost:11434'}/api/tags");
  
      final request = http.Request("GET", uri);
  
      final headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $_apiKey'
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

      _modelOptions = newOptions;
      return true;
    }
    catch (e) {
      if (!e.toString().contains(RegExp(r'Connection (failed|refused)'))) {
        rethrow;
      }
      return false;
    }
  }

  @override
  Map<String, dynamic> toMap() => {
    'model': _model,
    'overrides': _overrides,
    'base_url': _baseUrl,
    'api_key': _apiKey,
    'search_local_network': _searchLocalNetwork,
  };

  @override
  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _overrides = map['overrides'] ?? {};
    _baseUrl = map['base_url'];
    _apiKey = map['api_key'];
    _searchLocalNetwork = map['search_local_network'];
    save();
    notifyListeners();
  }
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.ollama;
  
  @override
  bool get canGetRemoteModels => baseUrl != null || searchLocalNetwork == true;
}

class OpenAIController extends RemoteArtificialIntelligenceController {
  late open_ai.OpenAIClient _openAiClient;

  @override
  String get type => 'open_ai';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  OpenAIController({
    super.model,
    super.overrides,
    super.baseUrl, 
    super.apiKey
  });

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_apiKey != null, 'API Key is required');
    assert(_model != null, 'Model is required');
    busy = true;

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.openai.com/v1';
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    final completionStream = _openAiClient.createChatCompletionStream(
      request: open_ai.CreateChatCompletionRequest(
        messages: messages.toOpenAiMessages(),
        model: open_ai.ChatCompletionModel.modelId(_model!),
        stream: true,
        temperature: _overrides['temperature'],
        topP: _overrides['top_p'],
        maxTokens: _overrides['max_tokens'],
        frequencyPenalty: _overrides['frequency_penalty'],
        presencePenalty: _overrides['presence_penalty'],
      )
    );

    try {
      await for (final completion in completionStream) {
        yield completion.choices.first.delta.content ?? '';
      }
    }
    catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    }
    finally {
      busy = false;
    }
  }

  @override
  void stop() {
    _openAiClient.endSession();
    busy = false;
  }
  
  @override
  Future<bool> getModelOptions() async {
    assert(_apiKey != null && _apiKey!.isNotEmpty, 'API Key is required');

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.openai.com/v1';
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    final modelsResponse = await _openAiClient.listModels();

    _modelOptions = modelsResponse.data.map((model) => model.id).toList();
    return true;
  }
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.openAI;
  
  @override
  bool get canGetRemoteModels => apiKey != null && apiKey!.isNotEmpty;
}

class MistralController extends RemoteArtificialIntelligenceController {
  late mistral.MistralAIClient _mistralClient;

  @override
  String get type => 'mistral';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  MistralController({
    super.model, 
    super.overrides,
    super.baseUrl, 
    super.apiKey
  });
  
  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_apiKey != null, 'API Key is required');
    assert(_model != null, 'Model is required');
    busy = true;

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.mistral.ai/v1';
    }

    _mistralClient = mistral.MistralAIClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    mistral.ChatCompletionModels mistralModel;

    if (_model == 'mistral-medium') {
      mistralModel = mistral.ChatCompletionModels.mistralMedium;
    } 
    else if (_model == 'mistral-small') {
      mistralModel = mistral.ChatCompletionModels.mistralSmall;
    } 
    else if (_model == 'mistral-tiny') {
      mistralModel = mistral.ChatCompletionModels.mistralTiny;
    } 
    else {
      throw Exception('Unknown Mistral model: $model');
    }

    final completionStream = _mistralClient.createChatCompletionStream(
      request: mistral.ChatCompletionRequest(
        messages: messages.toMistralMessages(),
        model: mistral.ChatCompletionModel.model(mistralModel),
        stream: true,
        temperature: _overrides['temperature'],
        topP: _overrides['top_p'],
        maxTokens: _overrides['max_tokens'],
        randomSeed: _overrides['seed'],
      )
    );

    try {
      await for (final completion in completionStream) {
        yield completion.choices.first.delta.content ?? '';
      }
    }
    catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    }
    finally {
      busy = false;
    }
  }
  
  @override
  void stop() {
    _mistralClient.endSession();
    busy = false;
  }

  @override
  Future<bool> getModelOptions() async {
    _modelOptions = [
      'mistral-medium',
      'mistral-small',
      'mistral-tiny',
    ];
    return true;
  }
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.mistral;
  
  @override
  bool get canGetRemoteModels => true;
}