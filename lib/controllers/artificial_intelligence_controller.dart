part of 'package:maid/main.dart';

abstract class AIController extends ChangeNotifier {
  static ValueNotifier<AIController?> notifier = ValueNotifier(null);
  static AIController get instance => notifier.value ?? defaultController;
  static set instance(AIController newInstance) {
    if (notifier.value != null) {
      notifier.value!.save();
    }

    notifier.value = newInstance;
  }

  static AIController get defaultController => kIsWeb ? OpenAIController() : LlamaCppController();

  static Map<String, String> getTypes(BuildContext context) {
    Map<String, String> types = {};

    if (!kIsWeb) {
      types['llama_cpp'] = AppLocalizations.of(context)!.llamaCpp;
    }

    types['ollama'] = AppLocalizations.of(context)!.ollama;
    types['open_ai'] = AppLocalizations.of(context)!.openAI;
    types['mistral'] = AppLocalizations.of(context)!.mistral;
    types['anthropic'] = AppLocalizations.of(context)!.anthropic;
    //types['google_gemini'] = AppLocalizations.of(context)!.gemini;

    return types;
  }

  bool _busy = false;

  bool get busy => _busy;

  set busy(bool value) {
    _busy = value;
    save();
    notifyListeners();
  }

  String? _model;

  String? get model => _model;

  set model(String? value) {
    _model = value;
    save();
    notifyListeners();
  }

  Map<String, dynamic> _parameters;

  Map<String, dynamic> get parameters => _parameters;

  set parameters(Map<String, dynamic> value) {
    _parameters = value;
    save();
    notifyListeners();
  }

  List<String> _modelOptions = [];

  List<String> get modelOptions => _modelOptions;

  String get type;
  bool get canPrompt;
  String get hash => jsonEncode(toMap()).hash;

  AIController({
    String? model, 
    Map<String, dynamic>? parameters
  }) : _model = model , _parameters = parameters ?? {};

  Map<String, dynamic> toMap() => {
    'model': _model,
    'parameters': _parameters,
  };

  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _parameters = map['parameters'] ?? {};
    save();
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('ai_type', type);

    final contextString = jsonEncode(toMap());

    await prefs.setString(type, contextString);
  }

  static Future<void> load([String? type]) async {
    final prefs = await SharedPreferences.getInstance();

    type ??= prefs.getString('ai_type') ?? (kIsWeb ? 'ollama' : 'llama_cpp');

    final contextString = prefs.getString(type);

    final contextMap = jsonDecode(contextString ?? '{}');

    switch (type) {
      case 'llama_cpp':
        instance = LlamaCppController()
          ..fromMap(contextMap);
        break;
      case 'ollama':
        instance = OllamaController()
          ..fromMap(contextMap);
        break;
      case 'open_ai':
        instance = OpenAIController()
          ..fromMap(contextMap);
        break;
      case 'mistral':
        instance = MistralController()
          ..fromMap(contextMap);
        break;
      case 'anthropic':
        instance = AnthropicController()
          ..fromMap(contextMap);
        break;
      default:
        instance = kIsWeb ? OpenAIController() : LlamaCppController();
    }
  }

  Stream<String> prompt();

  void stop();

  void clear() async {
    _model = null;
    _parameters = {};
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(type);
    await prefs.remove('ai_type');
  }

  String getTypeLocale(BuildContext context);

  void notify() => notifyListeners();
}

abstract class RemoteAIController extends AIController {
  static RemoteAIController? get instance => AIController.instance is RemoteAIController
    ? AIController.instance as RemoteAIController
    : null;

  static List<String> get types => [
    'ollama',
    'open_ai',
    'mistral',
    'anthropic'
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

  RemoteAIController({
    super.model, 
    super.parameters,
    String? baseUrl, 
    String? apiKey
  }) : _baseUrl = baseUrl, _apiKey = apiKey;

  @override
  Map<String, dynamic> toMap() => {
    'model': _model,
    'parameters': _parameters,
    'base_url': _baseUrl,
    'api_key': _apiKey
  };

  @override
  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _parameters = map['parameters'] ?? {};
    _baseUrl = map['base_url'];
    _apiKey = map['api_key'];
    save();
    notifyListeners();
  }

  Future<bool> getModelOptions();

  @override
  void clear() async {
    _model = null;
    _parameters = {};
    _baseUrl = null;
    _apiKey = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(type);
    await prefs.remove('ai_type');
  }
}

class LlamaCppController extends AIController {
  static LlamaCppController? get instance => AIController.instance is LlamaCppController
    ? AIController.instance as LlamaCppController
    : null;

  llama.Llama? _llama;
  String _loadedHash = '';

  bool loading = false;

  @override
  String get type => 'llama_cpp';

  @override
  bool get canPrompt => _llama != null && !busy;

  LlamaCppController({
    super.model, 
    super.parameters
  }) {
    getLoadedModels();
  }

  @override
  Stream<String> prompt() async* {
    assert(_model != null);
    busy = true;

    reloadModel();
    assert(_llama != null);

    yield* _llama!.prompt(ChatController.instance.root.toLlamaMessages());
    busy = false;
  }

  void reloadModel([bool force = false]) async {
    if ((hash == _loadedHash && !force) || _model == null) return;

    _llama = llama.Llama(
      llama.LlamaController.fromMap({
        'model_path': _model,
        'seed': math.Random().nextInt(1000000),
        'greedy': true,
        ..._parameters
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
    _modelOptions.removeWhere((model) => model == _model);
    _modelOptions.add(_model!);

    final exists = await File(_model!).exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    notifyListeners();
  }

  void loadModelFile(String path, [bool notify = false]) async {
    assert (RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _model = path;
    reloadModel();

    if (notify) notifyListeners();
  }

  void getLoadedModels() async {
    final prefs = await SharedPreferences.getInstance();
    _modelOptions = prefs.getStringList('loaded_models') ?? [];
    notifyListeners();
  }

  void addModelFile( path) async {
    assert (RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _modelOptions.removeWhere((model) => model == path);
    _modelOptions.add(path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('loaded_models', _modelOptions);

    reloadModel();
  }

  void removeLoadedModel(String path) async {
    assert (RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _modelOptions.removeWhere((model) => model == path);

    if (_model == path) {
      _model = null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('loaded_models', _modelOptions);

    notifyListeners();
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

class OllamaController extends RemoteAIController {
  static OllamaController? get instance => AIController.instance is OllamaController
    ? AIController.instance as OllamaController
    : null;

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
    super.parameters,
    super.baseUrl, 
    super.apiKey
  });

  @override
  Stream<String> prompt() async* {
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
        messages: ChatController.instance.root.toOllamaMessages(),
        options: ollama.RequestOptions.fromJson(_parameters),
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
    final dio = Dio();
  
    dio.options.headers.addAll({
      "Accept": "application/json",
      'Authorization': 'Bearer $_apiKey',
    });
  
    try {
      final response = await dio.getUri(url);
  
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

      final dio = Dio();
      final url = "${_baseUrl ?? 'http://localhost:11434'}/api/tags";

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $_apiKey",
          },
        ),
      );

      final data = response.data;

      List<String> newOptions = [];
      if (data['models'] != null) {
        for (final option in data['models']) {
          newOptions.add(option['name']);
        }
      }

      _modelOptions = newOptions;
      return true;
    } catch (e) {
      if (!e.toString().contains(RegExp(r'Connection (failed|refused)'))) {
        rethrow;
      }
      return false;
    }
  }

  @override
  Map<String, dynamic> toMap() => {
    'model': _model,
    'parameters': _parameters,
    'base_url': _baseUrl,
    'api_key': _apiKey,
    'search_local_network': _searchLocalNetwork,
  };

  @override
  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _parameters = map['parameters'] ?? {};
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

class OpenAIController extends RemoteAIController {
  static OpenAIController? get instance => AIController.instance is OpenAIController
    ? AIController.instance as OpenAIController
    : null;

  late open_ai.OpenAIClient _openAiClient;

  @override
  String get type => 'open_ai';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  OpenAIController({
    super.model,
    super.parameters,
    super.baseUrl, 
    super.apiKey
  });

  @override
  Stream<String> prompt() async* {
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
        messages: ChatController.instance.root.toOpenAiMessages(),
        model: open_ai.ChatCompletionModel.modelId(_model!),
        stream: true,
        temperature: _parameters['temperature'],
        topP: _parameters['top_p'],
        maxTokens: _parameters['max_tokens'],
        frequencyPenalty: _parameters['frequency_penalty'],
        presencePenalty: _parameters['presence_penalty'],
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

class MistralController extends RemoteAIController {
  static MistralController? get instance => AIController.instance is MistralController
    ? AIController.instance as MistralController
    : null;

  late mistral.MistralAIClient _mistralClient;

  @override
  String get type => 'mistral';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  MistralController({
    super.model, 
    super.parameters,
    super.baseUrl, 
    super.apiKey
  });
  
  @override
  Stream<String> prompt() async* {
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
        messages: ChatController.instance.root.toMistralMessages(),
        model: mistral.ChatCompletionModel.model(mistralModel),
        stream: true,
        temperature: _parameters['temperature'],
        topP: _parameters['top_p'],
        maxTokens: _parameters['max_tokens'],
        randomSeed: _parameters['seed'],
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

class AnthropicController extends RemoteAIController {
  static AnthropicController? get instance => AIController.instance is AnthropicController
    ? AIController.instance as AnthropicController
    : null;

  late anthropic.AnthropicClient _anthropicClient;

  @override
  String get type => 'anthropic';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  AnthropicController({
    super.model, 
    super.parameters,
    super.baseUrl, 
    super.apiKey
  });

  @override
  Stream<String> prompt() async* {
    assert(_apiKey != null, 'API Key is required');
    assert(_model != null, 'Model is required');
    busy = true;

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.anthropic.com/v1';
    }

    _anthropicClient = anthropic.AnthropicClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    final completionStream = _anthropicClient.createMessageStream(
      request: anthropic.CreateMessageRequest(
        model: anthropic.Model.model(anthropic.Models.values.firstWhere((model) => model.name == _model)),
        maxTokens: _parameters['max_tokens'] ?? 1024,
        messages: ChatController.instance.root.toAnthropicMessages(),
        stopSequences: _parameters['stop_sequences'],
        temperature: _parameters['temperature'],
        topK: _parameters['top_k'],
        topP: _parameters['top_p'],
        stream: true,
      )
    );

    try {
      await for (final completion in completionStream) {
        if (completion is! anthropic.ContentBlockDeltaEvent) continue;

        yield completion.delta.text;
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
    _anthropicClient.endSession();
    busy = false;
  }

  @override
  Future<bool> getModelOptions() async {
    _modelOptions = anthropic.Models.values.map((model) => model.name).toList();

    return true;
  }
  
  @override
  bool get canGetRemoteModels => true;
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.anthropic;
}
