import 'dart:convert';
import 'dart:ui';

import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:maid_llm/maid_llm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MistralAiModel extends LargeLanguageModel {
  @override
  LargeLanguageModelType get type => LargeLanguageModelType.mistralAI;

  MistralAiModel({
    super.listener, 
    super.name,
    super.uri = 'https://api.mistral.ai',
    super.token,
    super.useDefault,
    super.seed,
    super.temperature,
    super.topP
  });

  MistralAiModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    if (json['uri'] == null) json['uri'] = 'https://api.mistral.ai';
    super.fromMap(json);
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
    };
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) async* {
    try {
      //Unimplemented
    } catch (e) {
      Logger.log('Error: $e');
    }
  }
  
  @override
  Future<void> updateOptions() async {
    options = ["mistral-small", "mistral-medium"];
  }
  
  @override
  Future<void> resetUri() async {
    uri = 'https://api.mistral.ai';

    await updateOptions();
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("mistral_ai_model", json.encode(toMap()));
    });
  }
}