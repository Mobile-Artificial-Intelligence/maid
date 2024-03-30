abstract class LLM {
  late int seed;
  late double temperature;

  LLM({
    this.seed = 0, 
    this.temperature = 0.8
  });

  LLM.fromJson(Map<String, dynamic> json) {
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