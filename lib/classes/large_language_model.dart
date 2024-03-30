import 'package:langchain/langchain.dart';

abstract class LargeLanguageModel {
  AiPlatformType get type => AiPlatformType.none;

  late String name;
  late int seed;
  late double temperature;
  late bool useDefault;

  LargeLanguageModel({
    this.name = '',
    this.seed = 0, 
    this.temperature = 0.8,
    this.useDefault = false
  });

  LargeLanguageModel.fromMap(Map<String, dynamic> json) {
    fromMap(json);
  }

  void fromMap(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    seed = json['seed'] ?? 0;
    temperature = json['temperature'] ?? 0.8;
    useDefault = json['useDefault'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'seed': seed,
      'temperature': temperature,
      'useDefault': useDefault
    };
  }

  Stream<String> prompt(List<ChatMessage> messages);

  Future<List<String>> getOptions();

  Future<void> resetUrl();
}

enum AiPlatformType { none, llamacpp, openAI, ollama, mistralAI, custom }