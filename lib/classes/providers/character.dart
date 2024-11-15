import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:maid/classes/providers/characters.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:image/image.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Character extends ChangeNotifier {
  final Key _key;
  File? _profile;

  bool _useSystem = true;
  String _name = "大模型助手";
  String _description = "";
  String _personality = "";
  String _scenario = "";
  String _system = "";

  bool _useGreeting = false;
  List<String> _greetings = [];

  bool _useExamples = true;
  List<Map<String, dynamic>> _examples = [];

  Map<String, dynamic> _cachedJson = {};

  static Character of(BuildContext context) => CharacterCollection.of(context).current;

  Character(VoidCallback? listener) : _key = UniqueKey() {
    if (listener != null) {
      addListener(listener);
    }

    reset();
  }

  Character.fromMap(VoidCallback? listener, Map<String, dynamic> inputJson) : _key = UniqueKey() {
    if (listener != null) {
      addListener(listener);
    }

    fromMap(inputJson);
  }

  static Future<Character> get last async {
    final prefs = await SharedPreferences.getInstance();

    String? lastCharacterString = prefs.getString("last_character");

    Map<String, dynamic> lastCharacter = json.decode(lastCharacterString ?? "{}");
    
    return Character.fromMap(null, lastCharacter);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_character", json.encode(toMap()));
  }

  void notify() {
    notifyListeners();
  }

  void from(Character character) async {
    _profile = await character.profile;
    _useSystem = character.useSystem;
    _name = character.name;
    _description = character.description;
    _personality = character.personality;
    _scenario = character.scenario;
    _useGreeting = character.useGreeting;
    _greetings = character.greetings;
    _system = character.system;
    _useExamples = character.useExamples;
    _examples = character.examples;

    notifyListeners();
  }

  Future<void> fromMap(Map<String, dynamic> inputJson) async {
    if (inputJson["profile"] != null) {
      _profile = File(inputJson["profile"]);
    }
    else if (_profile == null || _profile!.path.contains("defaultAssistant")) {
      _profile = await Utilities.fileFromAssetImage("defaultAssistant.png");
    }

    if (inputJson["spec"] == "mcf_v1") {
      Logger.log("Character loaded from MCF");
      fromMCFMap(inputJson);
    } 
    else if (inputJson["spec"] == "chara_card_v2") {
      Logger.log("Character loaded from STV2");
      fromSTV2Map(inputJson);
    }
    else if (inputJson["first_mes"] != null) {
      Logger.log("Character loaded from STV1");
      fromSTV1Map(inputJson);
    }
    else {
      await reset();
    }

    _useExamples = _examples.isNotEmpty;
    notifyListeners();
  }

  void fromMCFMap(Map<String, dynamic> inputJson) {
    _name = inputJson["name"] ?? "Unknown";
    _useSystem = inputJson["use_preprompt"] ?? true;
    _description = inputJson["description"] ?? "";
    _personality = inputJson["personality"] ?? "";
    _scenario = inputJson["scenario"] ?? "";
    _system = inputJson["system_prompt"] ?? "";

    _useGreeting = inputJson["use_greeting"] ?? false;
    _greetings = List<String>.from(inputJson["greetings"]);
    
    _useExamples = inputJson["use_examples"] ?? false;
    if (inputJson["examples"] != null) {
      _examples = List<Map<String, dynamic>>.generate(
        inputJson["examples"].length ?? 0, 
        (i) => inputJson["examples"][i]
      );
    }

    _cachedJson = inputJson;
  }

  void fromSTV1Map(Map<String, dynamic> inputJson) {
    _name = inputJson["name"] ?? "Unknown";
    _description = inputJson["description"] ?? "";
    _personality = inputJson["personality"] ?? "";
    _scenario = inputJson["scenario"] ?? "";
    _greetings = [inputJson["first_mes"] ?? ""];
    _examples = examplesFromString(inputJson["mes_example"] ?? "");
    _cachedJson = inputJson;
  }

  void fromSTV2Map(Map<String, dynamic> inputJson) {
    if (inputJson["data"] != null) {
      Map<String, dynamic> data = inputJson["data"];

      fromSTV1Map(data);

      _system = inputJson["system_prompt"] ?? "";

      final alternateGreetings = data["alternate_greetings"];
      if (alternateGreetings != null) {
          _greetings.addAll(
              alternateGreetings.map<String>((item) => item.toString()).toList());
      }
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> jsonCharacter = {};

    jsonCharacter["spec"] = "mcf_v1";
    jsonCharacter["profile"] = _profile?.path;
    jsonCharacter["use_preprompt"] = _useSystem;
    jsonCharacter["name"] = _name;
    jsonCharacter["description"] = _description;
    jsonCharacter["personality"] = _personality;
    jsonCharacter["scenario"] = _scenario;
    jsonCharacter["use_greeting"] = _useGreeting;
    jsonCharacter["greetings"] = _greetings;
    jsonCharacter["system_prompt"] = _system;
    jsonCharacter["use_examples"] = _useExamples;
    jsonCharacter["examples"] = _examples;

    return jsonCharacter;
  }

  Map<String, dynamic> toMCFMap() {
    Map<String, dynamic> jsonCharacter = _cachedJson;

    jsonCharacter["spec"] = "mcf_v1";
    jsonCharacter["name"] = _name;
    jsonCharacter["description"] = _description;
    jsonCharacter["personality"] = _personality;
    jsonCharacter["scenario"] = _scenario;
    jsonCharacter["greetings"] = _greetings;
    jsonCharacter["system_prompt"] = _system;
    jsonCharacter["examples"] = _examples;

    return jsonCharacter;
  }

  Map<String, dynamic> toSTV1Map() {
    Map<String, dynamic> jsonCharacter = _cachedJson;

    jsonCharacter["name"] = _name;
    jsonCharacter["description"] = _description;
    jsonCharacter["personality"] = _personality;
    jsonCharacter["scenario"] = _scenario;
    jsonCharacter["first_mes"] = _greetings.firstOrNull ?? "";
    jsonCharacter["mes_example"] = examplesToString();

    return jsonCharacter;
  }

  Map<String, dynamic> toSTV2Map() {
    Map<String, dynamic> jsonCharacter = {};

    jsonCharacter["spec"] = "chara_card_v2";
    jsonCharacter["spec_version"] = "2.0";

    Map<String, dynamic> data = toSTV1Map();
    data["system_prompt"] = _system;
    data["alternate_greetings"] = _greetings.sublist(1);

    jsonCharacter["data"] = data;

    return jsonCharacter;
  }

  set name(String newName) {
    _name = newName;
    notifyListeners();
  }

  set useSystem(bool useSystem) {
    _useSystem = useSystem;
    notifyListeners();
  }

  set description(String newDescription) {
    _description = newDescription;
    notifyListeners();
  }

  set personality(String newPersonality) {
    _personality = newPersonality;
    notifyListeners();
  }

  set scenario(String newScenario) {
    _scenario = newScenario;
    notifyListeners();
  }

  set system(String newSystem) {
    _system = newSystem;
    notifyListeners();
  }

  set useGreeting(bool useGreeting) {
    _useGreeting = useGreeting;
    notifyListeners();
  }

  void newGreeting() {
    _greetings.add("");
    notifyListeners();
  }

  void updateGreeting(int index, String newGreeting) {
    _greetings[index] = newGreeting;
    notifyListeners();
  }

  void removeGreeting(int index) {
    _greetings.removeAt(index);
    notifyListeners();
  }

  void removeLastGreeting() {
    _greetings.removeLast();
    notifyListeners();
  }

  set useExamples(bool useExamples) {
    _useExamples = useExamples;
    notifyListeners();
  }

  void newExample(bool? user) {
    _examples.addAll([
      {
        "role": user == null ? "system" : user ? "user" : "assistant",
        "content": "",
      }
    ]);
    notifyListeners();
  }

  void updateExample(int index, String value) {
    _examples[index]["content"] = value;
    notifyListeners();
  }

  void removeLastExample() {
    _examples.removeLast();
    notifyListeners();
  }

  Future<File> get profile async {
    return _profile ??= await Utilities.fileFromAssetImage("defaultAssistant.png");
  }

  Key get key => _key;

  Key get imageKey {
    Uint8List bytes;

    if(_profile != null) {
      bytes = _profile!.readAsBytesSync();
    } 
    else {
      List<String> hashList = [
        _name,
        _description,
        _personality,
        _scenario,
        _system,
        _useGreeting.toString(),
        _greetings.join(),
        _useExamples.toString(),
        _examples.join(),
        _key.toString(),
      ];
      
      bytes = utf8.encode(hashList.join());
    }

    final hash = sha256.convert(bytes).toString();

    return ValueKey(hash);
  }

  String get name => _name;

  bool get useSystem => _useSystem;

  String get description => _description;

  String get personality => _personality;

  String get scenario => _scenario;

  bool get useGreeting => _useGreeting;

  List<String> get greetings => _greetings;

  String get system => _system;

  bool get useExamples => _useExamples;

  List<Map<String, dynamic>> get examples => _examples;

  Future<void> reset() async {
    _profile = await Utilities.fileFromAssetImage("defaultAssistant.png");

    final jsonString = await rootBundle.loadString('assets/default_assistant.json');

    Map<String, dynamic> jsonCharacter = json.decode(jsonString);

    await fromMap(jsonCharacter);

    Logger.log("Character reset");

    notifyListeners();
  }

  Future<String> exportMCF() async {
    return await _exportJSON(true);
  }

  Future<String> exportSTV2() async {
    return await _exportJSON(false);
  }

  Future<String> _exportJSON(bool mcf) async {
    try {
      // Convert the map to a JSON string
      String jsonString = json.encode(mcf ? toMCFMap() : toSTV2Map());

      String? result = await FilePicker.platform.saveFile(
        dialogTitle: "Save Character JSON",
        type: FileType.any,
        bytes: utf8.encode(jsonString),
      );

      if (result == null) {
        throw Exception("File not saved");
      }

      return "Character Successfully Saved";
    } catch (e) {
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> importJSON() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Load Character JSON",
        type: FileType.any,
        allowMultiple: false,
        allowCompression: false
      );

      File file;
      if (result != null && result.files.isNotEmpty) {
        Logger.log("File selected: ${result.files.single.path}");
        file = File(result.files.single.path!);
      } else {
        Logger.log("No file selected");
        throw Exception("File is null");
      }

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return "Failed to load character";

      Map<String, dynamic> jsonCharacter = json.decode(jsonString);

      if (jsonCharacter.isEmpty) {
        reset();
        return "Failed to decode character";
      }

      fromMap(jsonCharacter);
      return "Character Successfully Loaded";
    } catch (e) {
      reset();
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> exportImage() async {
    try {
      final image = decodeImage(_profile!.readAsBytesSync());

      if (image == null) throw "Error decoding image";

      String mcfMap = "";

      try {
        mcfMap = json.encode(toMCFMap());
      } catch (e) {
        Exception("Error encoding MCF Map: $e");
      }

      String stv2Map = "";

      try {
        stv2Map = base64.encode(utf8.encode(json.encode(toSTV2Map())));
      } catch (e) {
        Exception("Error encoding STV2 Map: $e");
      }

      image.textData = {
        "mcf": mcfMap,
        "chara": stv2Map
      };

      String? result = await FilePicker.platform.saveFile(
        dialogTitle: "Save Character Image",
        type: FileType.image,
        bytes: encodePng(image),
      );

      if (result == null) {
        throw Exception("File not saved");
      }

      return "Character Successfully Saved";
    } catch (e) {
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> importImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Load Character Image",
        type: FileType.any,
        allowMultiple: false,
        allowCompression: false
      );

      File file;
      if (result != null && result.files.isNotEmpty) {
        Logger.log("File selected: ${result.files.single.path}");
        file = File(result.files.single.path!);
      } else {
        Logger.log("No file selected");
        throw Exception("File is null");
      }

      final bytes = file.readAsBytesSync();

      final image = decodeImage(bytes);

      bool characterLoaded = false;
      if (image != null && image.textData != null) {
        if (image.textData!["Mcf"] != null ||
            image.textData!["mcf"] != null
        ) {
          Map<String, dynamic> jsonCharacter = json.decode(
            image.textData!["Mcf"] ?? image.textData!["mcf"]!
          );

          await fromMap(jsonCharacter);
          characterLoaded = true;
        }
        else if (
          image.textData!["Chara"] != null || 
          image.textData!["chara"] != null
        ) {
          Uint8List  utf8Character = base64.decode(
            image.textData!["Chara"] ?? image.textData!["chara"]!
          );
          String stringCharacter = utf8.decode(utf8Character);
          Map<String, dynamic> jsonCharacter = json.decode(stringCharacter);

          await fromMap(jsonCharacter);
          characterLoaded = true;
        }
      }

      Directory docDir = await getApplicationDocumentsDirectory();
      File newProfileFile = File('${docDir.path}/$_name.png');
      await newProfileFile.writeAsBytes(bytes);

      _profile = newProfileFile;

      notifyListeners();
      if (characterLoaded) {
        return "Character Successfully Loaded";
      } else {
        return "Image Successfully Loaded";
      }
    } catch (e) {
      await reset();
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  List<Map<String, dynamic>> examplesFromString(String examplesString) {
    // Split the input string into blocks, each starting with <START>
    final blocks = examplesString
        .split(RegExp(r'<START>', caseSensitive: false))
        .where((block) => block.trim().isNotEmpty);

    List<Map<String, dynamic>> examples = [];

    for (var block in blocks) {
      // Split each block into lines
      final lines =
          block.trim().split('\n').where((line) => line.trim().isNotEmpty);

      for (var line in lines) {
        final roleAndContent = RegExp(r'\{\{(\w+)\}\}:\s*(.*)');
        final match = roleAndContent.firstMatch(line.trim());

        if (match != null) {
          final role =
              match.group(1)!.toLowerCase() == 'user' ? 'user' : 'assistant';
          final content = match.group(2)!.trim();

          examples.add({
            "role": role,
            "content": content,
          });
        }
      }
    }

    return examples;
  }

  String examplesToString() {
    StringBuffer buffer = StringBuffer();

    for (var i = 0; i < _examples.length; i += 2) {
      buffer.writeln('<START>');
      buffer.writeln('{{user}}: ${_examples[i]["content"]}');
      if (i + 1 < _examples.length) {
        buffer.writeln('{{char}}:${_examples[i + 1]["content"]}');
      }
    }

    return buffer.toString();
  }
}
