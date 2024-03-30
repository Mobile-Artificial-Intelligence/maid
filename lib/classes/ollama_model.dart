import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class OllamaModel extends LargeLanguageModel {
  late String name;
  late String ip;
  late String url;

  late int nKeep;
  late int nCtx;
  late int nBatch;
  late int nThread;
  late int nPredict;
  late int topK;
  late int penaltyLastN;
  late int mirostat;

  late double topP;
  late double minP;
  late double tfsZ;
  late double typicalP;
  late double penaltyRepeat;
  late double penaltyPresent;
  late double penaltyFreq;
  late double mirostatTau;
  late double mirostatEta;

  late bool penalizeNewline;

  OllamaModel({
    super.seed,
    super.temperature,
    super.useDefault,
    this.name = '',
    this.ip = '',
    this.url = '',
    this.nKeep = 48,
    this.nCtx = 512,
    this.nBatch = 512,
    this.nThread = 8,
    this.nPredict = 512,
    this.topK = 40,
    this.penaltyLastN = 64,
    this.mirostat = 0,
    this.topP = 0.95,
    this.minP = 0.1,
    this.tfsZ = 1.0,
    this.typicalP = 1.0,
    this.penaltyRepeat = 1.1,
    this.penaltyPresent = 0.0,
    this.penaltyFreq = 0.0,
    this.mirostatTau = 5.0,
    this.mirostatEta = 0.1,
    this.penalizeNewline = true,
  });

  OllamaModel.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    name = json['name'] ?? '';
    ip = json['ip'] ?? '';
    url = json['url'] ?? '';

    nKeep = json['nKeep'] ?? 48;
    nCtx = json['nCtx'] ?? 512;
    nBatch = json['nBatch'] ?? 512;
    nThread = json['nThread'] ?? 8;
    nPredict = json['nPredict'] ?? 512;
    topK = json['topK'] ?? 40;
    penaltyLastN = json['penaltyLastN'] ?? 64;
    mirostat = json['mirostat'] ?? 0;

    topP = json['topP'] ?? 0.95;
    minP = json['minP'] ?? 0.1;
    tfsZ = json['tfsZ'] ?? 1.0;
    typicalP = json['typicalP'] ?? 1.0;
    penaltyRepeat = json['penaltyRepeat'] ?? 1.1;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyFreq = json['penaltyFreq'] ?? 0.0;
    mirostatTau = json['mirostatTau'] ?? 5.0;
    mirostatEta = json['mirostatEta'] ?? 0.1;

    penalizeNewline = json['penalizeNewline'] ?? true;
    useDefault = json['useDefault'] ?? true;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'name': name,
      'ip': ip,
      'url': url,
      'nKeep': nKeep,
      'nCtx': nCtx,
      'nBatch': nBatch,
      'nThread': nThread,
      'nPredict': nPredict,
      'topK': topK,
      'penaltyLastN': penaltyLastN,
      'mirostat': mirostat,
      'topP': topP,
      'minP': minP,
      'tfsZ': tfsZ,
      'typicalP': typicalP,
      'penaltyRepeat': penaltyRepeat,
      'penaltyPresent': penaltyPresent,
      'penaltyFreq': penaltyFreq,
      'mirostatTau': mirostatTau,
      'mirostatEta': mirostatEta,
      'penalizeNewline': penalizeNewline,
    };
  }

  Future<void> resetUrl() async {
    if (ip.isNotEmpty && (await _checkIpForOllama(ip)).isNotEmpty) {
      url = 'http://$ip:11434';
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
    ip = validUrls.isNotEmpty ? validUrls.first : '';

    url = 'http://$ip:11434';
  }

  Future<String> _checkIpForOllama(String ip) async {
    final url = Uri.parse('http://$ip:11434');
    final headers = {"Accept": "application/json"};

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
  Stream<String> prompt(List<ChatMessage> messages) async* {
    try {
      ChatOllama chat;
      if (useDefault) {
        chat = ChatOllama(
          baseUrl: '$url/api',
          defaultOptions: ChatOllamaOptions(
            model: name,
          ),
        );
      } else {
        chat = ChatOllama(
          baseUrl: '$url/api',
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

      final stream = chat.stream(PromptValue.chat(messages));

      await for (final ChatResult response in stream) {
        yield response.firstOutputAsString;
      }
    } catch (e) {
      Logger.log('Error: $e');
    }
  }
}