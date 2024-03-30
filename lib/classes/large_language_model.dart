import 'package:langchain/langchain.dart';

abstract class LargeLanguageModel {
  late int seed;
  late double temperature;
  late bool useDefault;

  LargeLanguageModel({
    this.seed = 0, 
    this.temperature = 0.8,
    this.useDefault = false
  });

  LargeLanguageModel.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  void fromJson(Map<String, dynamic> json) {
    seed = json['seed'] ?? 0;
    temperature = json['temperature'] ?? 0.8;
    useDefault = json['useDefault'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'seed': seed,
      'temperature': temperature,
      'useDefault': useDefault
    };
  }

  Stream<String> prompt(List<ChatMessage> messages);
}