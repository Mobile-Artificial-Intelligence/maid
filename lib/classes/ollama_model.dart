import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OllamaModel extends LargeLanguageModel {
  @override
  LargeLanguageModelType get type => LargeLanguageModelType.ollama;
  
  String _ip = '';

  @override
  List<String> get missingRequirements {
    List<String> missing = [];

    if (name.isEmpty) {
      missing.add('- A model option is required for prompting.\n');
    } 
    
    if (uri.isEmpty) {
      missing.add('- A compatible URL is required for prompting.\n');
    }
    
    return missing;
  }

  OllamaModel({
    super.listener, 
    super.name,
    super.uri,
    super.token,
    super.useDefault,
    super.penalizeNewline,
    super.seed,
    super.nKeep,
    super.nPredict,
    super.topK,
    super.topP,
    super.tfsZ,
    super.typicalP,
    super.temperature,
    super.penaltyLastN,
    super.penaltyRepeat,
    super.penaltyPresent,
    super.penaltyFreq,
    super.mirostat,
    super.mirostatTau,
    super.mirostatEta,
    super.nCtx,
    super.nBatch,
    super.nThread,
    String ip = '',
  }) {
    _ip = ip;
  }

  OllamaModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    _ip = json['ip'] ?? '';
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'ip': _ip,
    };
  }

  @override
  Future<void> resetUri() async {
    // Check Localhost
    if ((await _checkIpForOllama('127.0.0.1')).isNotEmpty) {
      uri = 'http://127.0.0.1:11434';
      notifyListeners();
      return;
    }
    
    // If ip is set, check if it's valid
    if (_ip.isNotEmpty && (await _checkIpForOllama(_ip)).isNotEmpty) {
      uri = 'http://$_ip:11434';
      notifyListeners();
      return;
    }

    bool permissionGranted = await _getNearbyDevicesPermission();
    if (!permissionGranted) {
      return;
    }

    final localIP = await NetworkInfo().getWifiIP();

    // Get the first 3 octets of the local IP
    final baseIP = ipToCSubnet(localIP ?? '');

    // Scan the local network for hosts
    final hosts =
        await LanScanner(debugLogging: true).quickIcmpScanAsync(baseIP);

    // Create a list to hold all the futures
    var futures = <Future<String>>[];

    for (var host in hosts) {
      futures.add(_checkIpForOllama(host.internetAddress.address));
    }

    // Wait for all futures to complete
    final results = await Future.wait(futures);

    // Filter out all empty results and return the first valid URL, if any
    final validUrls = results.where((result) => result.isNotEmpty);
    _ip = validUrls.isNotEmpty ? validUrls.first : '';

    uri = 'http://$_ip:11434';

    notifyListeners();
  }

  Future<String> _checkIpForOllama(String ip) async {
    final url = Uri.parse('http://$ip:11434');
    final headers = {
      "Accept": "application/json",
      'Authorization': 'Bearer $token'
    };

    try {
      var request = Request("GET", url)..headers.addAll(headers);
      var response = await request.send();
      if (response.statusCode == 200) {
        Logger.log('Found Ollama at $ip');
        return ip;
      }
    } catch (e) {
      // Ignore
    }

    return '';
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) async* {
    List<ChatMessage> chatMessages = [];

    for (var message in messages) {
      Logger.log("Message: ${message.content}");
      if (message.content.isEmpty) {
        continue;
      }

      switch (message.role) {
        case ChatRole.user:
          chatMessages.add(ChatMessage.humanText(message.content));
          break;
        case ChatRole.assistant:
          chatMessages.add(ChatMessage.ai(message.content));
          break;
        case ChatRole.system: // Under normal circumstances, this should only be used for preprompt
          chatMessages.add(ChatMessage.system(message.content));
          break;
        default:
          break;
      }
    }

    try {
      bool permissionGranted = await _getNearbyDevicesPermission();
      if (!permissionGranted) {
        throw Exception('Permission denied');
      }

      ChatOllama chat;
      if (useDefault) {
        chat = ChatOllama(
          baseUrl: '$uri/api',
          headers: { 'Authorization': 'Bearer $token' },
          defaultOptions: ChatOllamaOptions(
            model: name,
            seed: seed
          ),
        );
      } else {
        chat = ChatOllama(
          baseUrl: '$uri/api',
          headers: { 'Authorization': 'Bearer $token' },
          defaultOptions: ChatOllamaOptions(
            model: name,
            numKeep: nKeep,
            seed: seed,
            numPredict: nPredict,
            topK: topK,
            topP: topP,
            typicalP: typicalP,
            temperature: temperature,
            repeatPenalty: penaltyRepeat,
            frequencyPenalty: penaltyFreq,
            presencePenalty: penaltyPresent,
            mirostat: mirostat,
            mirostatTau: mirostatTau,
            mirostatEta: mirostatEta,
            numCtx: nCtx,
            numBatch: nBatch,
            numThread: nThread,
          ),
        );
      }

      final stream = chat.stream(PromptValue.chat(chatMessages));

      yield* stream.map((final res) => res.output.content);
    } catch (e) {
      Logger.log('Error: $e');
    }
  }
  
  @override
  Future<List<String>> get options async {
    try {
      bool permissionGranted = await _getNearbyDevicesPermission();
      if (!permissionGranted) {
        return [];
      }
  
      final url = Uri.parse("$uri/api/tags");
      final headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $token'
      };

      var request = Request("GET", url)..headers.addAll(headers);

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
      Logger.log('Error: $e');
      return [];
    }
  }

  Future<bool> _getNearbyDevicesPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    // Get sdk version
    final sdk = await DeviceInfoPlugin()
        .androidInfo
        .then((value) => value.version.sdkInt);
    var permissions = <Permission>[]; // List of permissions to request

    if (sdk <= 32) {
      // ACCESS_FINE_LOCATION is required
      permissions.add(Permission.location);
    } else {
      // NEARBY_WIFI_DEVICES is required
      permissions.add(Permission.nearbyWifiDevices);
    }

    // Request permissions and check if all are granted
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    bool allPermissionsGranted =
        statuses.values.every((status) => status.isGranted);

    if (allPermissionsGranted) {
      Logger.log("Nearby Devices - permission granted");
      return true;
    } else {
      Logger.log("Nearby Devices - permission denied");
      return false;
    }
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("ollama_model", json.encode(toMap()));
    });
  }

  @override
  void reset() {
    fromMap({});
  }
}