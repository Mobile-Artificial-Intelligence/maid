abstract class LargeLanguageModel {
  late int seed;
  late double temperature;

  LargeLanguageModel({
    this.seed = 0, 
    this.temperature = 0.8
  });

  LargeLanguageModel.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  void fromJson(Map<String, dynamic> json) {
    seed = json['seed'] ?? 0;
    temperature = json['temperature'] ?? 0.8;
  }

  Map<String, dynamic> toJson() {
    return {
      'seed': seed,
      'temperature': temperature
    };
  }
}