import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:maid/static/file_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Character extends ChangeNotifier {
  Key _key = UniqueKey();
  File _profile = File("assets/defaultCharacter.png");
  String _name = "Maid";
  String _description = "";
  String _personality = "";
  String _scenario = "";

  bool _useGreeting = false;
  List<String> _greetings = [];
  String _system = "";

  bool _useExamples = true;
  List<Map<String, dynamic>> _examples = [];

  Map<String, dynamic> _cachedJson = {};

  Character() {
    init();
  }

  Character.fromMap(Map<String, dynamic> inputJson) {
    fromMap(inputJson);
  }

  void newCharacter() {
    final key = UniqueKey().toString();
    _name = "New Character $key";
    reset();
  }

  void notify() {
    notifyListeners();
  }

  void init() async {
    Logger.log("Character Initialised");

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastCharacter =
        json.decode(prefs.getString("last_character") ?? "{}");

    if (lastCharacter.isNotEmpty) {
      Logger.log(lastCharacter.toString());
      fromMap(lastCharacter);
    } else {
      reset();
    }
  }

  Character copy() {
    Character newCharacter = Character();
    newCharacter.from(this);
    return newCharacter;
  }

  void from(Character character) {
    _key = character.key;
    _profile = character.profile;
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

  void fromMap(Map<String, dynamic> inputJson) async {
    if (inputJson["profile"] != null) {
      _profile = File(inputJson["profile"]);
    } 
    else {
      Directory docDir = await getApplicationDocumentsDirectory();
      String filePath = '${docDir.path}/defaultCharacter.png';

      File newProfileFile = File(filePath);
      if (!await newProfileFile.exists()) {
        ByteData data = await rootBundle.load('assets/defaultCharacter.png');
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await newProfileFile.writeAsBytes(bytes);
      }

      _profile = newProfileFile;
    }

    if (inputJson.isEmpty) {
      reset();
    }

    if (inputJson["spec"] == "mcf_v1") {
      fromMCFMap(inputJson);
    } 
    else if (inputJson["spec"] == "chara_card_v2") {
      fromSTV2Map(inputJson);
    }
    else if (inputJson["first_mes"] != null) {
      fromSTV1Map(inputJson);
    }
    else {
      reset();
    }

    Logger.log("Character created with name: ${inputJson["name"]}");
    _useGreeting = _greetings.isNotEmpty;
    _useExamples = _examples.isNotEmpty;
    notifyListeners();
  }

  void fromMCFMap(Map<String, dynamic> inputJson) {
    _name = inputJson["name"] ?? "Unknown";
    _description = inputJson["description"] ?? "";
    _personality = inputJson["personality"] ?? "";
    _scenario = inputJson["scenario"] ?? "";

    _greetings = List<String>.from(inputJson["greetings"]);

    _system = inputJson["system_prompt"] ?? "";
    
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

    jsonCharacter["profile"] = _profile.path;

    jsonCharacter["name"] = _name;
    jsonCharacter["description"] = _description;
    jsonCharacter["personality"] = _personality;
    jsonCharacter["scenario"] = _scenario;
    jsonCharacter["use_greeting"] = _useGreeting;
    jsonCharacter["greetings"] = _greetings;
    jsonCharacter["first_mes"] = _greetings.firstOrNull ?? "";
    jsonCharacter["alternate_greetings"] = _greetings.sublist(1);
    jsonCharacter["system_prompt"] = _system;

    jsonCharacter["use_examples"] = _useExamples;
    jsonCharacter["examples"] = _examples;
    jsonCharacter["mes_example"] = examplesToString();

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

  void newExample() {
    _examples.addAll([
      {
        "role": "user",
        "content": "",
      },
      {
        "role": "assistant",
        "content": "",
      }
    ]);
    notifyListeners();
  }

  void updateExample(int index, String value) {
    _examples[index]["content"] = value;
    notifyListeners();
  }

  void removeExample(int index) {
    _examples.removeRange(index - 2, index);
    notifyListeners();
  }

  void removeLastExample() {
    _examples.removeRange(_examples.length - 2, _examples.length);
    notifyListeners();
  }

  Key get key => _key;

  File get profile => _profile;

  String get name => _name;

  String get description => _description;

  String get personality => _personality;

  String get scenario => _scenario;

  bool get useGreeting => _useGreeting;

  List<String> get greetings => _greetings;

  String get system => _system;

  bool get useExamples => _useExamples;

  List<Map<String, dynamic>> get examples => _examples;

  void reset() {
    // Reset all the internal state to the defaults
    rootBundle.loadString('assets/default_character.json').then((jsonString) {
      Map<String, dynamic> jsonCharacter = json.decode(jsonString);

      fromMap(jsonCharacter);

      notifyListeners();
    });
  }

  Future<String> exportMCF(BuildContext context) async {
    return await _exportJSON(context, true);
  }

  Future<String> exportSTV2(BuildContext context) async {
    return await _exportJSON(context, false);
  }

  Future<String> _exportJSON(BuildContext context, bool mcf) async {
    try {
      // Convert the map to a JSON string
      String jsonString = json.encode(mcf ? toMCFMap() : toSTV2Map());

      File? file = await FileManager.save(context, "$_name.json");

      if (file == null) return "Error saving file";

      await file.writeAsString(jsonString);

      return "Character Successfully Saved to ${file.path}";
    } catch (e) {
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> importJSON(BuildContext context) async {
    try {
      File? file =
          await FileManager.load(context, "Load Character JSON", [".json"]);

      if (file == null) return "Error loading file";

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

  Future<String> exportImage(BuildContext context) async {
    try {
      final image = decodeImage(_profile.readAsBytesSync());

      if (image == null) return "Error decoding image";

      image.textData = {
        "Mcf_v1": json.encode(toMCFMap()),
        "Chara": base64.encode(utf8.encode(json.encode(toSTV2Map())))
      };

      File? file = await FileManager.save(context, "$_name.png");

      if (file == null) return "Error saving file";

      await file.writeAsBytes(encodePng(image));

      return "Character Successfully Saved";
    } catch (e) {
      Logger.log("Error: $e");
      return "Error: $e";
    }
  }

  Future<String> importImage(BuildContext context) async {
    try {
      File? file = await FileManager.loadImage(context, "Load Character Image");

      if (file == null) return "Error loading file";

      final image = decodePng(file.readAsBytesSync());

      if (image != null && image.textData != null) {
        if (image.textData!["Mcf_v1"] != null) {
          Map<String, dynamic> jsonCharacter =
              json.decode(image.textData!["Mcf_v1"]!);

          fromMap(jsonCharacter);
        }
        else if (image.textData!["Chara"] != null) {
          Map<String, dynamic> jsonCharacter =
              json.decode(utf8.decode(base64.decode(image.textData!["Chara"]!)));

          fromMap(jsonCharacter);
        }
      }

      Directory docDir = await getApplicationDocumentsDirectory();
      String filePath = '${docDir.path}/$_name.png';

      File newProfileFile = File(filePath);
      if (!await newProfileFile.exists()) {
        ByteData data = await file
            .readAsBytes()
            .then((bytes) => ByteData.view(bytes.buffer));
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await newProfileFile.writeAsBytes(bytes);
      }

      _profile = newProfileFile;

      notifyListeners();
      return "Character Successfully Loaded";
    } catch (e) {
      reset();
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
