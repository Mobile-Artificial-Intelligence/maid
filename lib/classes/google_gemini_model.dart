import 'dart:convert';
import 'dart:ui';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:langchain/langchain.dart';
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
  Stream<String> prompt(List<ChatMessage> messages) async* {
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

  (List<Content>, Content) _toContent(List<ChatMessage> messages) {
    List<Content> history = [];
    Content? content;

    for (var message in messages) {
      if (message is SystemChatMessage) {
        history.add(Content.text(message.contentAsString));
      } else if (message is HumanChatMessage) {
        if (content != null) {
          history.add(content);
        }

        content = Content.text(message.contentAsString);
      } else if (message is AIChatMessage) {
        history.add(Content.model([TextPart(message.contentAsString)]));
      } else {
        throw Exception('Unknown ChatMessage type');
      }
    }

    content ??= Content.text(''); // If there is no prompt, add an empty prompt

    return (history, content);
  }
  
  @override
  Future<void> updateOptions() async {
    options = ["gemini-pro", "gemini-pro-vision"];
  }
  
  @override
  Future<void> resetUri() async {
    uri = ''; // No URI to reset

    await updateOptions();
    notifyListeners();
  }

  @override
  void save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("google_gemini_model", json.encode(toMap()));
    });
  }
}