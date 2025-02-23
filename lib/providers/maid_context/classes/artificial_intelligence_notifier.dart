part of 'package:maid/main.dart';

abstract class ArtificialIntelligenceNotifier extends ChangeNotifier {
  static List<String> get types => [
    'llama_cpp',
    'ollama',
    'open_ai',
    'mistral',
  ];

  bool _busy = false;

  bool get busy => _busy;

  set busy(bool newBusy) {
    _busy = newBusy;
    notifyListeners();
  }

  String? _model;

  String? get model => _model;

  set model(String? newModel) {
    _model = newModel;
    notifyListeners();
  }

  Map<String, dynamic> _overrides;

  Map<String, dynamic> get overrides => _overrides;

  set overrides(Map<String, dynamic> newOverrides) {
    _overrides = newOverrides;
    notifyListeners();
  }

  String get type;
  bool get canPrompt;
  String get hash => jsonEncode(toMap()).hash;

  ArtificialIntelligenceNotifier({
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
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final contextString = jsonEncode(toMap());

    prefs.setString(type, contextString);
  }

  static Future<ArtificialIntelligenceNotifier> load(String type) async {
    final prefs = await SharedPreferences.getInstance();

    final contextString = prefs.getString(type);

    final contextMap = jsonDecode(contextString ?? '{}');

    switch (type) {
      case 'llama_cpp':
        return LlamaCppNotifier()
          ..fromMap(contextMap);
      case 'ollama':
        return OllamaNotifier()
          ..fromMap(contextMap);
      case 'open_ai':
        return OpenAINotifier()
          ..fromMap(contextMap);
      case 'mistral':
        return MistralNotifier()
          ..fromMap(contextMap);
      default:
        return LlamaCppNotifier();
    }
  }

  Stream<String> prompt(List<ChatMessage> messages);

  void stop();
}

abstract class RemoteArtificialIntelligenceNotifier extends ArtificialIntelligenceNotifier {
  static List<String> get types => [
    'ollama',
    'open_ai',
    'mistral',
  ];

  String? _baseUrl;

  String? get baseUrl => _baseUrl;

  set baseUrl(String? newBaseUrl) {
    _baseUrl = newBaseUrl;
    notifyListeners();
  }

  String? _apiKey;

  String? get apiKey => _apiKey;

  set apiKey(String? newApiKey) {
    _apiKey = newApiKey;
    notifyListeners();
  }

  RemoteArtificialIntelligenceNotifier({
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
    notifyListeners();
  }

  Future<List<String>> getModelOptions();
}

class LlamaCppNotifier extends ArtificialIntelligenceNotifier {
  Llama? _llama;
  String _loadedHash = '';

  bool loading = false;

  @override
  String get type => 'llama_cpp';

  @override
  bool get canPrompt => _llama != null && !busy;

  LlamaCppNotifier({
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
      modelParams: ModelParams(
        path: _model!,
        vocabOnly: _overrides['vocab_only'],
        useMmap: _overrides['use_mmap'],
        useMlock: _overrides['use_mlock'],
        checkTensors: _overrides['check_tensors']
      ),
      contextParams: ContextParams.fromMap(_overrides),
      samplingParams: SamplingParams.fromMap({..._overrides, 'greedy': true, 'seed': math.Random().nextInt(1000000)})
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
  void stop() => _llama?.stop();

  @override
  void notifyListeners() {
    super.notifyListeners();
    reloadModel();
    save();
  }
}

class OllamaNotifier extends RemoteArtificialIntelligenceNotifier {
  late ollama.OllamaClient _ollamaClient;

  bool? _searchLocalNetwork;

  bool? get searchLocalNetwork => _searchLocalNetwork;

  set searchLocalNetwork(bool? value) {
    _searchLocalNetwork = value;
    notifyListeners();
  }

  @override
  String get type => 'ollama';

  @override
  bool get canPrompt => _model != null && _model!.isNotEmpty && !busy;

  OllamaNotifier({
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
  void stop() => _ollamaClient.endSession();

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
  Future<List<String>> getModelOptions() async {
    try {
      if (searchLocalNetwork == true) {
        final found = await searchForOllama();
        if (!found) return [];
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

      return newOptions;
    }
    catch (e) {
      if (!e.toString().contains(RegExp(r'Connection (failed|refused)'))) {
        rethrow;
      }
      return [];
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
    notifyListeners();
  }
}

class OpenAINotifier extends RemoteArtificialIntelligenceNotifier {
  late open_ai.OpenAIClient _openAiClient;

  @override
  String get type => 'open_ai';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  OpenAINotifier({
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
  void stop() => _openAiClient.endSession();
  
  @override
  Future<List<String>> getModelOptions() async {
    assert(_apiKey != null && _apiKey!.isNotEmpty, 'API Key is required');

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.openai.com/v1';
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    final modelsResponse = await _openAiClient.listModels();

    return modelsResponse.data.map((model) => model.id).toList();
  }
}

class MistralNotifier extends RemoteArtificialIntelligenceNotifier {
  late mistral.MistralAIClient _mistralClient;

  @override
  String get type => 'mistral';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  MistralNotifier({
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
  void stop() => _mistralClient.endSession();

  @override
  Future<List<String>> getModelOptions() async => [
    'mistral-medium',
    'mistral-small',
    'mistral-tiny',
  ];
}