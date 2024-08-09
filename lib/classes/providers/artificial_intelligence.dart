import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/classes/providers/large_language_models/google_gemini_model.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/classes/providers/large_language_models/mistral_ai_model.dart';
import 'package:maid/classes/providers/large_language_models/ollama_model.dart';
import 'package:maid/classes/providers/large_language_models/open_ai_model.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtificialIntelligence extends ChangeNotifier {
  LargeLanguageModel llm = LargeLanguageModel();

  static ArtificialIntelligence of(BuildContext context, { bool listen = false }) => Provider.of<ArtificialIntelligence>(context, listen: listen);

  static Future<ArtificialIntelligence> get last async {
    final prefs = await SharedPreferences.getInstance();

    final llmTypeInt = prefs.getInt("llm_type") ?? LargeLanguageModelType.ollama.index;

    final llmType = LargeLanguageModelType.values[llmTypeInt];

    final ai = ArtificialIntelligence(llmType);

    return ai;
  }

  ArtificialIntelligence(LargeLanguageModelType llmType) {
    switchLargeLanguageModel(llmType);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final futures = [
      prefs.setInt("llm_type", llm.type.index),
      llm.save()
    ];

    await Future.wait(futures);
  }

  void reset() {
    llm.reset();
    notify();
  }

  void notify() {
    save().then((_) => notifyListeners());
  }

  void switchLargeLanguageModel(LargeLanguageModelType type) {
    if (llm.type != LargeLanguageModelType.none) {
      llm.save();
    }

    switch (type) {
      case LargeLanguageModelType.llamacpp:
        _switchLlamaCpp();
        break;
      case LargeLanguageModelType.openAI:
        _switchOpenAI();
        break;
      case LargeLanguageModelType.ollama:
        _switchOllama();
        break;
      case LargeLanguageModelType.mistralAI:
        _switchMistralAI();
        break;
      case LargeLanguageModelType.gemini:
        _switchGemini();
        break;
      default:
        _switchLlamaCpp();
        break;
    }
  }

  void _switchLlamaCpp() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastLlamaCpp = json.decode(prefs.getString("llama_cpp_model") ?? "{}");
    Logger.log(lastLlamaCpp.toString());
    
    if (lastLlamaCpp.isNotEmpty) {
      llm = LlamaCppModel.fromMap(notify, lastLlamaCpp);
    } 
    else {
      llm = LlamaCppModel(listener: notify);
    }

    await prefs.setInt("llm_type", llm.type.index);
    notify();
  }

  void _switchOpenAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOpenAI = json.decode(prefs.getString("open_ai_model") ?? "{}");
    Logger.log(lastOpenAI.toString());
    
    if (lastOpenAI.isNotEmpty) {
      llm = OpenAiModel.fromMap(notify, lastOpenAI);
    } 
    else {
      llm = OpenAiModel(listener: notify);
    }

    await prefs.setInt("llm_type", llm.type.index);
    notify();
  }

  void _switchOllama() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOllama = json.decode(prefs.getString("ollama_model") ?? "{}");
    Logger.log(lastOllama.toString());
    
    if (lastOllama.isNotEmpty) {
      llm = OllamaModel.fromMap(notify, lastOllama);
    } 
    else {
      llm = OllamaModel(listener: notify);
      llm.resetUri();
    }

    prefs.setInt("llm_type", llm.type.index);
    notify();
  }

  void _switchMistralAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastMistralAI = json.decode(prefs.getString("mistral_ai_model") ?? "{}");
    Logger.log(lastMistralAI.toString());
    
    if (lastMistralAI.isNotEmpty) {
      llm = MistralAiModel.fromMap(notify, lastMistralAI);
    } 
    else {
      llm = MistralAiModel(listener: notify);
    }

    prefs.setInt("llm_type", llm.type.index);
    notify();
  }

  void _switchGemini() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastGemini = json.decode(prefs.getString("google_gemini_model") ?? "{}");
    Logger.log(lastGemini.toString());
    
    if (lastGemini.isNotEmpty) {
      llm = GoogleGeminiModel.fromMap(notify, lastGemini);
    } 
    else {
      llm = GoogleGeminiModel(listener: notify);
    }

    prefs.setInt("llm_type", llm.type.index);
    notify();
  }
}