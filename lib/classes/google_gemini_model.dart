import 'dart:convert';
import 'dart:ui';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/classes/large_language_model.dart';
import 'package:maid/static/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleGeminiModel extends LargeLanguageModel {
  @override
  LargeLanguageModelType get type => LargeLanguageModelType.gemini;

  GoogleGeminiModel({
    super.listener, 
    super.name = 'gemini-pro',
    super.token,
    super.nPredict,
    super.temperature,
    super.topP,
    super.topK
  });

  GoogleGeminiModel.fromMap(VoidCallback listener, Map<String, dynamic> json) {
    addListener(listener);
    fromMap(json);
  }

  @override
  List<String> get missingRequirements {
    List<String> missing = [];

    if (name.isEmpty) {
      missing.add('- A model option is required for prompting.\n');
    }

    if (token.isEmpty) {
      missing.add('- An authentication token is required for prompting.\n');
    } 
    
    return missing;
  }

  @override
  Stream<String> prompt(List<ChatNode> messages) async* {
    try {
      final model = GenerativeModel(
        model: name, 
        apiKey: token,
        generationConfig: GenerationConfig(
          maxOutputTokens: nPredict,
          temperature: temperature,
          topP: topP,
          topK: topK
        )
      );

      final (history, content) = _toContent(messages);

      final chat = model.startChat(
        history: history
      );

      final stream = chat.sendMessageStream(content);

      await for (final response in stream) {
        final output = response.text;

        if (output != null) {
          yield output;
        }
      }
    } catch (e) {
      Logger.log('Error: $e');
    }
  }

  (List<Content>, Content) _toContent(List<ChatNode> messages) {
    List<Content> history = [];
    Content? content;

    for (var message in messages) {
      switch (message.role) {
        case ChatRole.system:
          history.add(Content.text(message.content));
          break;
        case ChatRole.user:
          if (content != null) {
            history.add(content);
          }

          content = Content.text(message.content);
          break;
        case ChatRole.assistant:
          history.add(Content.model([TextPart(message.content)]));
          break;
      }
    }

    content ??= Content.text(''); // If there is no prompt, add an empty prompt

    return (history, content);
  }
  
  @override
  Future<List<String>> get options async {
    return ["gemini-pro", "gemini-pro-vision"];
  }
  
  @override
  Future<void> resetUri() async {
    uri = ''; // No URI to reset
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("google_gemini_model", json.encode(toMap()));
    });
  }

  @override
  void reset() {
    fromMap({});
  }
}