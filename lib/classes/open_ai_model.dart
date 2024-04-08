import 'dart:convert';
import 'dart:ui';

import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:maid_llm/maid_llm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenAiModel extends LargeLanguageModel {
  @override
  LargeLanguageModelType get type => LargeLanguageModelType.openAI;

  OpenAiModel({
    super.listener, 
    super.name,
    super.uri = 'https://api.openai.com/v1/',
    super.token,
    super.seed,
    super.nPredict,
    super.topP,
    super.penaltyPresent,
    super.penaltyFreq,
  });

  OpenAiModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  void fromMap(Map<String, dynamic> json) {
    super.fromMap(json);
    uri = json['url'] ?? 'https://api.openai.com/v1/';
    token = json['token'] ?? '';
    nPredict = json['nPredict'] ?? 512;
    topP = json['topP'] ?? 0.95;
    penaltyPresent = json['penaltyPresent'] ?? 0.0;
    penaltyFreq = json['penaltyFreq'] ?? 0.0;
    notifyListeners();
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
    options = ["gpt-3.5-turbo", "gpt-4-32k"];
  }
  
  @override
  Future<void> resetUri() async {
    uri = 'https://api.openai.com/v1/';

    await updateOptions();
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("open_ai_model", json.encode(toMap()));
    });
  }
}