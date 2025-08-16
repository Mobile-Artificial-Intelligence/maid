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

  static AIController get defaultController =>
      kIsWeb ? OpenAIController() : LlamaCppController();

  static Map<String, String> getTypes(BuildContext context) {
    Map<String, String> types = {};

    if (!kIsWeb) {
      types['llama_cpp'] = AppLocalizations.of(context)!.llamaCpp;
    }

    types['ollama'] = AppLocalizations.of(context)!.ollama;
    types['open_ai'] = AppLocalizations.of(context)!.openAI;
    types['mistral'] = AppLocalizations.of(context)!.mistral;
    types['anthropic'] = AppLocalizations.of(context)!.anthropic;
    types['azure_openai'] = AppLocalizations.of(context)!.azureOpenAI;
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

  AIController({String? model, Map<String, dynamic>? parameters})
      : _model = model,
        _parameters = parameters ?? {};

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
        instance = LlamaCppController()..fromMap(contextMap);
        break;
      case 'ollama':
        instance = OllamaController()..fromMap(contextMap);
        break;
      case 'open_ai':
        instance = OpenAIController()..fromMap(contextMap);
        break;
      case 'mistral':
        instance = MistralController()..fromMap(contextMap);
        break;
      case 'anthropic':
        instance = AnthropicController()..fromMap(contextMap);
        break;
      case 'azure_openai':
        instance = AzureOpenAIController()..fromMap(contextMap);
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
  static RemoteAIController? get instance =>
      AIController.instance is RemoteAIController
          ? AIController.instance as RemoteAIController
          : null;

  static List<String> get types =>
      ['ollama', 'open_ai', 'mistral', 'anthropic', 'azure_openai'];

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

  RemoteAIController(
      {super.model, super.parameters, String? baseUrl, String? apiKey})
      : _baseUrl = baseUrl,
        _apiKey = apiKey;

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
  static LlamaCppController? get instance =>
      AIController.instance is LlamaCppController
          ? AIController.instance as LlamaCppController
          : null;

  llama.Llama? _llama;
  String _loadedHash = '';

  bool loading = false;

  @override
  String get type => 'llama_cpp';

  @override
  bool get canPrompt => _llama != null && !busy;

  LlamaCppController({super.model, super.parameters}) {
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

    _llama = llama.Llama(llama.LlamaController.fromMap({
      'model_path': _model,
      'seed': math.Random().nextInt(1000000),
      'greedy': true,
      ..._parameters
    }));

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
        });

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
    assert(RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _model = path;
    reloadModel();

    if (notify) notifyListeners();
  }

  void getLoadedModels() async {
    final prefs = await SharedPreferences.getInstance();
    _modelOptions = prefs.getStringList('loaded_models') ?? [];
    notifyListeners();
  }

  void addModelFile(path) async {
    assert(RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _modelOptions.removeWhere((model) => model == path);
    _modelOptions.add(path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('loaded_models', _modelOptions);

    reloadModel();
  }

  void removeLoadedModel(String path) async {
    assert(RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
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
  String getTypeLocale(BuildContext context) =>
      AppLocalizations.of(context)!.llamaCpp;
}

class OllamaController extends RemoteAIController {
  static OllamaController? get instance =>
      AIController.instance is OllamaController
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

  OllamaController(
      {super.model, super.parameters, super.baseUrl, super.apiKey});

  @override
  Stream<String> prompt() async* {
    assert(_model != null);
    busy = true;

    _ollamaClient = ollama.OllamaClient(
        baseUrl: "${_baseUrl ?? 'http://localhost:11434'}/api",
        headers: {'Authorization': 'Bearer $_apiKey'});

    final completionStream = _ollamaClient.generateChatCompletionStream(
        request: ollama.GenerateChatCompletionRequest(
            model: _model!,
            messages: ChatController.instance.root.toOllamaMessages(),
            options: ollama.RequestOptions.fromJson(_parameters),
            stream: true));

    try {
      await for (final completion in completionStream) {
        yield completion.message.content;
      }
    } catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    } finally {
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
    if (_baseUrl != null &&
        await checkForOllama(Uri.parse(_baseUrl!)) != null) {
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
    final hosts =
        await LanScanner(debugLogging: true).quickIcmpScanAsync(baseIP);

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
  String getTypeLocale(BuildContext context) =>
      AppLocalizations.of(context)!.ollama;

  @override
  bool get canGetRemoteModels => baseUrl != null || searchLocalNetwork == true;
}

class OpenAIController extends RemoteAIController {
  static OpenAIController? get instance =>
      AIController.instance is OpenAIController
          ? AIController.instance as OpenAIController
          : null;

  late open_ai.OpenAIClient _openAiClient;

  @override
  String get type => 'open_ai';

  @override
  bool get canPrompt =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _model != null &&
      _model!.isNotEmpty &&
      !busy;

  OpenAIController(
      {super.model, super.parameters, super.baseUrl, super.apiKey});

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
    ));

    try {
      await for (final completion in completionStream) {
        yield completion.choices.first.delta?.content ?? '';
      }
    } catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    } finally {
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
  String getTypeLocale(BuildContext context) =>
      AppLocalizations.of(context)!.openAI;

  @override
  bool get canGetRemoteModels => apiKey != null && apiKey!.isNotEmpty;
}

class MistralController extends RemoteAIController {
  static MistralController? get instance =>
      AIController.instance is MistralController
          ? AIController.instance as MistralController
          : null;

  late mistral.MistralAIClient _mistralClient;

  @override
  String get type => 'mistral';

  @override
  bool get canPrompt =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _model != null &&
      _model!.isNotEmpty &&
      !busy;

  MistralController(
      {super.model, super.parameters, super.baseUrl, super.apiKey});

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
    } else if (_model == 'mistral-small') {
      mistralModel = mistral.ChatCompletionModels.mistralSmall;
    } else if (_model == 'mistral-tiny') {
      mistralModel = mistral.ChatCompletionModels.mistralTiny;
    } else {
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
    ));

    try {
      await for (final completion in completionStream) {
        yield completion.choices.first.delta.content ?? '';
      }
    } catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    } finally {
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
  String getTypeLocale(BuildContext context) =>
      AppLocalizations.of(context)!.mistral;

  @override
  bool get canGetRemoteModels => true;
}

class AnthropicController extends RemoteAIController {
  static AnthropicController? get instance =>
      AIController.instance is AnthropicController
          ? AIController.instance as AnthropicController
          : null;

  late anthropic.AnthropicClient _anthropicClient;

  @override
  String get type => 'anthropic';

  @override
  bool get canPrompt =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _model != null &&
      _model!.isNotEmpty &&
      !busy;

  AnthropicController(
      {super.model, super.parameters, super.baseUrl, super.apiKey});

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
      model: anthropic.Model.model(
          anthropic.Models.values.firstWhere((model) => model.name == _model)),
      maxTokens: _parameters['max_tokens'] ?? 1024,
      messages: ChatController.instance.root.toAnthropicMessages(),
      stopSequences: _parameters['stop_sequences'],
      temperature: _parameters['temperature'],
      topK: _parameters['top_k'],
      topP: _parameters['top_p'],
      stream: true,
    ));

    try {
      await for (final completion in completionStream) {
        if (completion is! anthropic.ContentBlockDeltaEvent) continue;

        yield completion.delta.text;
      }
    } catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    } finally {
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
  String getTypeLocale(BuildContext context) =>
      AppLocalizations.of(context)!.anthropic;
}

class AzureOpenAIController extends RemoteAIController {
  static AzureOpenAIController? get instance =>
      AIController.instance is AzureOpenAIController
          ? AIController.instance as AzureOpenAIController
          : null;

  String? _resourceName;
  String? _deploymentName;
  String? _apiVersion;

  String? get resourceName => _resourceName;
  set resourceName(String? value) {
    if (value != null && !_isValidResourceName(value)) {
      throw ArgumentError('Invalid Azure resource name: $value');
    }
    _resourceName = value;
    save();
    notifyListeners();
  }

  String? get deploymentName => _deploymentName;
  set deploymentName(String? value) {
    if (value != null && !_isValidDeploymentName(value)) {
      throw ArgumentError('Invalid Azure deployment name: $value');
    }
    _deploymentName = value;
    save();
    notifyListeners();
  }

  String? get apiVersion => _apiVersion;
  set apiVersion(String? value) {
    if (value != null && !_isValidApiVersion(value)) {
      throw ArgumentError('Invalid Azure API version: $value');
    }
    _apiVersion = value;
    save();
    notifyListeners();
  }

  @override
  String get type => 'azure_openai';

  @override
  bool get canPrompt =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _resourceName != null &&
      _resourceName!.isNotEmpty &&
      _deploymentName != null &&
      _deploymentName!.isNotEmpty &&
      !busy;

  @override
  set parameters(Map<String, dynamic> value) {
    _parameters = _validateAndSanitizeParameters(value);
    save();
    notifyListeners();
  }

  AzureOpenAIController({
    super.model,
    super.parameters,
    super.baseUrl,
    super.apiKey,
    String? resourceName,
    String? deploymentName,
    String? apiVersion,
  })  : _resourceName = resourceName,
        _deploymentName = deploymentName,
        _apiVersion = apiVersion ?? '2024-02-15-preview';

  @override
  Map<String, dynamic> toMap() => {
        'model': _model,
        'parameters': _parameters,
        'base_url': _baseUrl,
        'api_key': _apiKey,
        'resource_name': _resourceName,
        'deployment_name': _deploymentName,
        'api_version': _apiVersion,
      };

  @override
  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _parameters = _validateAndSanitizeParameters(map['parameters'] ?? {});
    _baseUrl = map['base_url'];
    _apiKey = map['api_key'];

    // Validate and set Azure-specific fields
    final resourceName = map['resource_name'] as String?;
    if (resourceName != null && !_isValidResourceName(resourceName)) {
      // Log warning but don't throw - allow loading with invalid data for recovery
      _resourceName = null;
    } else {
      _resourceName = resourceName;
    }

    final deploymentName = map['deployment_name'] as String?;
    if (deploymentName != null && !_isValidDeploymentName(deploymentName)) {
      // Log warning but don't throw - allow loading with invalid data for recovery
      _deploymentName = null;
    } else {
      _deploymentName = deploymentName;
    }

    final apiVersion = map['api_version'] as String? ?? '2024-02-15-preview';
    if (!_isValidApiVersion(apiVersion)) {
      // Fall back to default API version if invalid
      _apiVersion = '2024-02-15-preview';
    } else {
      _apiVersion = apiVersion;
    }

    save();
    notifyListeners();
  }

  @override
  Stream<String> prompt() async* {
    assert(_apiKey != null, 'API Key is required');
    assert(_resourceName != null, 'Resource name is required');
    assert(_deploymentName != null, 'Deployment name is required');

    busy = true;

    try {
      _azureClient = Dio();

      // Configure Azure OpenAI specific headers
      final headers = {
        'Content-Type': 'application/json',
        'api-key': _apiKey!,
      };

      // Prepare the request body in OpenAI format with validated parameters
      final requestBody = <String, dynamic>{
        'messages': ChatController.instance.root
            .toOpenAiMessages()
            .map((msg) => {
                  'role': msg.role.name,
                  'content': msg.content,
                })
            .toList(),
        'stream': true,
      };

      // Add validated parameters to request body
      final validatedParams = _validateAndSanitizeParameters(_parameters);
      requestBody.addAll(validatedParams);

      // Remove null parameters
      requestBody.removeWhere((key, value) => value == null);

      final response = await _azureClient.post(
        _chatCompletionsUrl,
        data: requestBody,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream<Uint8List>;
      String buffer = '';

      await for (final chunk in stream) {
        final chunkString = utf8.decode(chunk);
        buffer += chunkString;

        // Process complete lines
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete line in buffer

        for (final line in lines) {
          final trimmedLine = line.trim();

          // Skip empty lines and non-data lines
          if (trimmedLine.isEmpty || !trimmedLine.startsWith('data: ')) {
            continue;
          }

          final dataContent =
              trimmedLine.substring(6); // Remove 'data: ' prefix

          // Check for stream end
          if (dataContent == '[DONE]') {
            return;
          }

          try {
            final jsonData = jsonDecode(dataContent);

            // Extract content from Azure OpenAI response format
            if (jsonData['choices'] != null &&
                jsonData['choices'].isNotEmpty &&
                jsonData['choices'][0]['delta'] != null &&
                jsonData['choices'][0]['delta']['content'] != null) {
              final content =
                  jsonData['choices'][0]['delta']['content'] as String;
              if (content.isNotEmpty) {
                yield content;
              }
            }
          } catch (e) {
            // Skip malformed JSON chunks
            continue;
          }
        }
      }
    } catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        // Handle Azure OpenAI specific errors
        final errorMessage = _mapAzureError(e);
        throw Exception(errorMessage);
      }
    } finally {
      busy = false;
    }
  }

  late Dio _azureClient;

  @override
  void stop() {
    try {
      _azureClient.close(force: true);
    } catch (e) {
      // Client might not be initialized or already closed
    }
    busy = false;
  }

  @override
  Future<bool> getModelOptions() async {
    try {
      // Validate that we have the required configuration to fetch deployments
      if (_resourceName == null || _resourceName!.isEmpty) {
        return false;
      }
      if (_apiKey == null || _apiKey!.isEmpty) {
        return false;
      }
      if (_apiVersion == null || _apiVersion!.isEmpty) {
        return false;
      }

      // Create Dio client for making the request
      final client = Dio();

      // Configure timeouts for deployment discovery
      client.options.connectTimeout = const Duration(seconds: 10);
      client.options.receiveTimeout = const Duration(seconds: 10);

      // Make request to Azure OpenAI deployments endpoint
      final response = await client.get(
        _deploymentsUrl,
        options: Options(
          headers: _authHeaders,
        ),
      );

      // Parse the response to extract deployment names
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Azure OpenAI deployments API returns a 'data' array with deployment objects
        if (data['data'] != null && data['data'] is List) {
          final deployments = data['data'] as List;

          // Extract deployment names from the response
          final deploymentNames = <String>[];
          for (final deployment in deployments) {
            if (deployment is Map<String, dynamic> &&
                deployment['id'] != null) {
              deploymentNames.add(deployment['id'].toString());
            }
          }

          // Update model options with discovered deployments
          _modelOptions = deploymentNames;

          // If we found deployments, return success
          return deploymentNames.isNotEmpty;
        }
      }

      // If we couldn't parse deployments, fall back to empty list
      _modelOptions = [];
      return false;
    } catch (e) {
      // Handle Azure OpenAI specific errors gracefully
      final errorString = e.toString();

      // Don't rethrow connection errors, just return false
      if (errorString
          .contains(RegExp(r'Connection (failed|refused|timeout)'))) {
        _modelOptions = [];
        return false;
      }

      // Handle HTTP error responses
      if (errorString.contains('404')) {
        // Resource not found - likely invalid resource name
        _modelOptions = [];
        return false;
      } else if (errorString.contains('401')) {
        // Unauthorized - likely invalid API key
        _modelOptions = [];
        return false;
      } else if (errorString.contains('403')) {
        // Forbidden - API key doesn't have permission to list deployments
        _modelOptions = [];
        return false;
      }

      // For other errors, don't clear existing options but return false
      return false;
    }
  }

  @override
  void clear() {
    super.clear();
    _resourceName = null;
    _deploymentName = null;
    _apiVersion = '2024-02-15-preview';
  }

  @override
  String getTypeLocale(BuildContext context) =>
      AppLocalizations.of(context)!.azureOpenAI;

  @override
  bool get canGetRemoteModels =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _resourceName != null &&
      _resourceName!.isNotEmpty;

  /// Maps Azure OpenAI specific errors to user-friendly messages
  String _mapAzureError(dynamic error) {
    final errorString = error.toString();

    // Handle DioException specifically
    if (error is DioException) {
      if (error.response?.statusCode == 404) {
        if (errorString.contains('DeploymentNotFound') ||
            errorString.contains('deployment') ||
            errorString.contains('not found')) {
          return 'Deployment "$_deploymentName" not found in resource "$_resourceName". Please check your deployment name.';
        }
        return 'Azure OpenAI resource "$_resourceName" not found. Please check your resource name.';
      }

      if (error.response?.statusCode == 401) {
        return 'Invalid Azure OpenAI API key. Please check your API key and try again.';
      }

      if (error.response?.statusCode == 403) {
        return 'Access denied to Azure OpenAI resource "$_resourceName". Please check your permissions.';
      }

      if (error.response?.statusCode == 429) {
        return 'Azure OpenAI rate limit exceeded. Please wait and try again.';
      }

      if (error.response?.statusCode == 400) {
        final responseData = error.response?.data;
        if (responseData != null &&
            responseData.toString().contains('api-version')) {
          return 'Invalid API version "$_apiVersion". Please check the supported API versions.';
        }
        return 'Bad request to Azure OpenAI. Please check your configuration.';
      }

      // Handle connection errors
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timeout to Azure OpenAI resource "$_resourceName". Please check your network connection.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to Azure OpenAI resource "$_resourceName". Please check your resource name and network connection.';
      }
    }

    // Handle DNS resolution errors
    if (errorString.contains('Failed host lookup') ||
        errorString.contains('No address associated with hostname')) {
      return 'Cannot resolve Azure OpenAI resource "$_resourceName". Please check your resource name.';
    }

    // Handle SSL/TLS errors
    if (errorString.contains('CERTIFICATE_VERIFY_FAILED') ||
        errorString.contains('TLS') ||
        errorString.contains('SSL')) {
      return 'SSL/TLS error connecting to Azure OpenAI. Please check your network configuration.';
    }

    // Generic Azure OpenAI error
    if (errorString.contains('azure') || errorString.contains('openai')) {
      return 'Azure OpenAI error: ${error.toString()}';
    }

    // Fallback to original error
    return 'Error connecting to Azure OpenAI: ${error.toString()}';
  }

  /// Validates Azure resource name according to Azure naming conventions
  /// Resource names must be 1-63 characters, contain only alphanumeric characters and hyphens,
  /// start and end with alphanumeric characters, and not contain consecutive hyphens
  bool _isValidResourceName(String resourceName) {
    if (resourceName.isEmpty || resourceName.length > 63) {
      return false;
    }

    // Must start and end with alphanumeric character
    if (!RegExp(r'^[a-zA-Z0-9].*[a-zA-Z0-9]$').hasMatch(resourceName)) {
      return false;
    }

    // Can only contain alphanumeric characters and hyphens
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(resourceName)) {
      return false;
    }

    // Cannot contain consecutive hyphens
    if (resourceName.contains('--')) {
      return false;
    }

    return true;
  }

  /// Validates Azure deployment name according to Azure OpenAI naming conventions
  /// Deployment names must be 1-64 characters and contain only alphanumeric characters, hyphens, and underscores
  bool _isValidDeploymentName(String deploymentName) {
    if (deploymentName.isEmpty || deploymentName.length > 64) {
      return false;
    }

    // Can only contain alphanumeric characters, hyphens, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(deploymentName)) {
      return false;
    }

    return true;
  }

  /// Validates Azure OpenAI API version format
  /// API versions should follow the format YYYY-MM-DD or YYYY-MM-DD-preview
  bool _isValidApiVersion(String apiVersion) {
    if (apiVersion.isEmpty) {
      return false;
    }

    // Check for valid API version format: YYYY-MM-DD or YYYY-MM-DD-preview
    final apiVersionRegex = RegExp(r'^\d{4}-\d{2}-\d{2}(-preview)?$');
    return apiVersionRegex.hasMatch(apiVersion);
  }

  /// Constructs the base Azure OpenAI endpoint URL
  /// Format: https://{resource-name}.openai.azure.com
  String get _baseEndpoint {
    if (_resourceName == null || _resourceName!.isEmpty) {
      throw StateError(
          'Resource name is required to construct Azure OpenAI endpoint');
    }
    return 'https://$_resourceName.openai.azure.com';
  }

  /// Constructs the Azure OpenAI chat completions endpoint URL
  /// Format: https://{resource-name}.openai.azure.com/openai/deployments/{deployment-name}/chat/completions?api-version={api-version}
  String get _chatCompletionsUrl {
    if (_deploymentName == null || _deploymentName!.isEmpty) {
      throw StateError(
          'Deployment name is required to construct Azure OpenAI chat completions endpoint');
    }
    if (_apiVersion == null || _apiVersion!.isEmpty) {
      throw StateError(
          'API version is required to construct Azure OpenAI endpoint');
    }
    return '$_baseEndpoint/openai/deployments/$_deploymentName/chat/completions?api-version=$_apiVersion';
  }

  /// Constructs the Azure OpenAI deployments listing endpoint URL
  /// Format: https://{resource-name}.openai.azure.com/openai/deployments?api-version={api-version}
  String get _deploymentsUrl {
    if (_apiVersion == null || _apiVersion!.isEmpty) {
      throw StateError(
          'API version is required to construct Azure OpenAI endpoint');
    }
    return '$_baseEndpoint/openai/deployments?api-version=$_apiVersion';
  }

  /// Constructs Azure OpenAI authentication headers
  /// Uses api-key header instead of Authorization Bearer token
  Map<String, String> get _authHeaders {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw StateError('API key is required for Azure OpenAI authentication');
    }
    return {
      'Content-Type': 'application/json',
      'api-key': _apiKey!,
    };
  }

  /// Constructs Azure OpenAI request headers with authentication and content type
  Map<String, String> _buildRequestHeaders(
      [Map<String, String>? additionalHeaders]) {
    final headers = Map<String, String>.from(_authHeaders);
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  /// Validates that all required Azure OpenAI configuration is present for making requests
  void _validateConfiguration() {
    if (_resourceName == null || _resourceName!.isEmpty) {
      throw StateError('Azure resource name is required');
    }
    if (_deploymentName == null || _deploymentName!.isEmpty) {
      throw StateError('Azure deployment name is required');
    }
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw StateError('Azure OpenAI API key is required');
    }
    if (_apiVersion == null || _apiVersion!.isEmpty) {
      throw StateError('Azure OpenAI API version is required');
    }
  }

  /// Validates and sanitizes parameters according to Azure OpenAI constraints
  /// Returns a new map with validated parameters, removing invalid ones and applying defaults
  Map<String, dynamic> _validateAndSanitizeParameters(
      Map<String, dynamic> params) {
    final validatedParams = <String, dynamic>{};

    // Temperature: 0.0 to 2.0 (Azure OpenAI constraint)
    if (params.containsKey('temperature')) {
      final temp = params['temperature'];
      if (temp is num && temp >= 0.0 && temp <= 2.0) {
        validatedParams['temperature'] = temp.toDouble();
      }
    }

    // Top P: 0.0 to 1.0 (Azure OpenAI constraint)
    if (params.containsKey('top_p')) {
      final topP = params['top_p'];
      if (topP is num && topP >= 0.0 && topP <= 1.0) {
        validatedParams['top_p'] = topP.toDouble();
      }
    }

    // Max tokens: 1 to model-specific maximum (Azure OpenAI constraint)
    if (params.containsKey('max_tokens')) {
      final maxTokens = params['max_tokens'];
      if (maxTokens is num && maxTokens >= 1 && maxTokens <= 32768) {
        validatedParams['max_tokens'] = maxTokens.toInt();
      }
    }

    // Frequency penalty: -2.0 to 2.0 (Azure OpenAI constraint)
    if (params.containsKey('frequency_penalty')) {
      final freqPenalty = params['frequency_penalty'];
      if (freqPenalty is num && freqPenalty >= -2.0 && freqPenalty <= 2.0) {
        validatedParams['frequency_penalty'] = freqPenalty.toDouble();
      }
    }

    // Presence penalty: -2.0 to 2.0 (Azure OpenAI constraint)
    if (params.containsKey('presence_penalty')) {
      final presPenalty = params['presence_penalty'];
      if (presPenalty is num && presPenalty >= -2.0 && presPenalty <= 2.0) {
        validatedParams['presence_penalty'] = presPenalty.toDouble();
      }
    }

    // Stop sequences: array of up to 4 strings (Azure OpenAI constraint)
    if (params.containsKey('stop')) {
      final stop = params['stop'];
      if (stop is List && stop.length <= 4) {
        final validStop = stop
            .where((item) => item is String && item.isNotEmpty)
            .cast<String>()
            .toList();
        if (validStop.isNotEmpty) {
          validatedParams['stop'] = validStop;
        }
      } else if (stop is String && stop.isNotEmpty) {
        validatedParams['stop'] = [stop];
      }
    }

    // N (number of completions): 1 to 128 (Azure OpenAI constraint, but typically 1 for streaming)
    if (params.containsKey('n')) {
      final n = params['n'];
      if (n is num && n >= 1 && n <= 128) {
        validatedParams['n'] = n.toInt();
      }
    }

    // Logit bias: object with token IDs as keys and bias values from -100 to 100
    if (params.containsKey('logit_bias')) {
      final logitBias = params['logit_bias'];
      if (logitBias is Map<String, dynamic>) {
        final validLogitBias = <String, dynamic>{};
        for (final entry in logitBias.entries) {
          final tokenId = int.tryParse(entry.key);
          final bias = entry.value;
          if (tokenId != null && bias is num && bias >= -100 && bias <= 100) {
            validLogitBias[entry.key] = bias.toDouble();
          }
        }
        if (validLogitBias.isNotEmpty) {
          validatedParams['logit_bias'] = validLogitBias;
        }
      }
    }

    // User identifier: string for tracking purposes (Azure OpenAI supports this)
    if (params.containsKey('user')) {
      final user = params['user'];
      if (user is String && user.isNotEmpty && user.length <= 256) {
        validatedParams['user'] = user;
      }
    }

    // Seed: integer for deterministic sampling (Azure OpenAI supports this in newer versions)
    if (params.containsKey('seed')) {
      final seed = params['seed'];
      if (seed is num && seed >= -2147483648 && seed <= 2147483647) {
        validatedParams['seed'] = seed.toInt();
      }
    }

    return validatedParams;
  }

  /// Validates a specific parameter value according to Azure OpenAI constraints
  /// Returns true if the parameter is valid, false otherwise
  bool _isValidParameter(String key, dynamic value) {
    switch (key) {
      case 'temperature':
        return value is num && value >= 0.0 && value <= 2.0;
      case 'top_p':
        return value is num && value >= 0.0 && value <= 1.0;
      case 'max_tokens':
        return value is num && value >= 1 && value <= 32768;
      case 'frequency_penalty':
      case 'presence_penalty':
        return value is num && value >= -2.0 && value <= 2.0;
      case 'stop':
        if (value is List) {
          return value.length <= 4 &&
              value.every((item) => item is String && item.isNotEmpty);
        } else if (value is String) {
          return value.isNotEmpty;
        }
        return false;
      case 'n':
        return value is num && value >= 1 && value <= 128;
      case 'logit_bias':
        if (value is Map<String, dynamic>) {
          return value.entries.every((entry) {
            final tokenId = int.tryParse(entry.key);
            final bias = entry.value;
            return tokenId != null &&
                bias is num &&
                bias >= -100 &&
                bias <= 100;
          });
        }
        return false;
      case 'user':
        return value is String && value.isNotEmpty && value.length <= 256;
      case 'seed':
        return value is num && value >= -2147483648 && value <= 2147483647;
      default:
        // Allow unknown parameters but don't validate them
        return true;
    }
  }

  /// Gets the default value for a parameter if none is provided
  dynamic _getDefaultParameterValue(String key) {
    switch (key) {
      case 'temperature':
        return 1.0;
      case 'top_p':
        return 1.0;
      case 'max_tokens':
        return null; // Let Azure OpenAI decide based on model
      case 'frequency_penalty':
      case 'presence_penalty':
        return 0.0;
      case 'n':
        return 1;
      default:
        return null;
    }
  }

  /// Public method to validate a parameter for UI feedback
  /// Returns a validation result with error message if invalid
  Map<String, dynamic> validateParameter(String key, dynamic value) {
    final isValid = _isValidParameter(key, value);
    if (isValid) {
      return {'valid': true, 'message': null};
    }

    // Provide specific error messages for different parameter types
    switch (key) {
      case 'temperature':
        return {
          'valid': false,
          'message': 'Temperature must be between 0.0 and 2.0'
        };
      case 'top_p':
        return {'valid': false, 'message': 'Top P must be between 0.0 and 1.0'};
      case 'max_tokens':
        return {
          'valid': false,
          'message': 'Max tokens must be between 1 and 32768'
        };
      case 'frequency_penalty':
      case 'presence_penalty':
        return {
          'valid': false,
          'message': 'Penalty must be between -2.0 and 2.0'
        };
      case 'stop':
        return {
          'valid': false,
          'message': 'Stop sequences must be up to 4 non-empty strings'
        };
      case 'n':
        return {'valid': false, 'message': 'N must be between 1 and 128'};
      case 'user':
        return {
          'valid': false,
          'message':
              'User identifier must be a non-empty string up to 256 characters'
        };
      case 'seed':
        return {
          'valid': false,
          'message':
              'Seed must be an integer between -2147483648 and 2147483647'
        };
      default:
        return {'valid': false, 'message': 'Invalid parameter value'};
    }
  }

  /// Gets parameter constraints for UI display
  Map<String, dynamic> getParameterConstraints(String key) {
    switch (key) {
      case 'temperature':
        return {'min': 0.0, 'max': 2.0, 'default': 1.0, 'type': 'double'};
      case 'top_p':
        return {'min': 0.0, 'max': 1.0, 'default': 1.0, 'type': 'double'};
      case 'max_tokens':
        return {'min': 1, 'max': 32768, 'default': null, 'type': 'int'};
      case 'frequency_penalty':
      case 'presence_penalty':
        return {'min': -2.0, 'max': 2.0, 'default': 0.0, 'type': 'double'};
      case 'n':
        return {'min': 1, 'max': 128, 'default': 1, 'type': 'int'};
      case 'seed':
        return {
          'min': -2147483648,
          'max': 2147483647,
          'default': null,
          'type': 'int'
        };
      default:
        return {'type': 'string'};
    }
  }
}
