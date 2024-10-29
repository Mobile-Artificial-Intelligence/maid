import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppSettingsService {
  static const String _selectedCharacterKey = 'selected_character';
  static const String _selectedModelKey = 'selected_model';
  static const String _modelParametersKey = 'model_parameters';
  static const String _characterSettingsKey = 'character_settings';

  // Singleton instance
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save methods
  Future<void> saveSelectedCharacter(String characterId) async {
    await _prefs.setString(_selectedCharacterKey, characterId);
  }

  Future<void> saveSelectedModel(String modelId) async {
    await _prefs.setString(_selectedModelKey, modelId);
  }

  Future<void> saveModelParameters(Map<String, dynamic> parameters) async {
    await _prefs.setString(_modelParametersKey, jsonEncode(parameters));
  }

  Future<void> saveCharacterSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_characterSettingsKey, jsonEncode(settings));
  }

  // Load methods
  String? getSelectedCharacter() {
    return _prefs.getString(_selectedCharacterKey);
  }

  String? getSelectedModel() {
    return _prefs.getString(_selectedModelKey);
  }

  Map<String, dynamic>? getModelParameters() {
    final String? data = _prefs.getString(_modelParametersKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Map<String, dynamic>? getCharacterSettings() {
    final String? data = _prefs.getString(_characterSettingsKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // Clear methods
  Future<void> clearAllSettings() async {
    await _prefs.clear();
  }

  // Model-specific keys
  static const String _modelTemperatureKey = 'model_temperature';
  static const String _modelMaxTokensKey = 'model_max_tokens';
  static const String _modelTopPKey = 'model_top_p';
  static const String _modelTopKKey = 'model_top_k';
  static const String _modelContextLengthKey = 'model_context_length';

  Future<void> saveModelSettings({
    required String modelId,
    required double temperature,
    required int maxTokens,
    required double topP,
    required int topK,
    required int contextLength,
  }) async {
    await _prefs.setString(_selectedModelKey, modelId);
    await _prefs.setDouble(_modelTemperatureKey, temperature);
    await _prefs.setInt(_modelMaxTokensKey, maxTokens);
    await _prefs.setDouble(_modelTopPKey, topP);
    await _prefs.setInt(_modelTopKKey, topK);
    await _prefs.setInt(_modelContextLengthKey, contextLength);
  }

  ModelSettings? getModelSettings() {
    final modelId = _prefs.getString(_selectedModelKey);
    if (modelId == null) return null;

    return ModelSettings(
      modelId: modelId,
      temperature: _prefs.getDouble(_modelTemperatureKey) ?? 0.7,
      maxTokens: _prefs.getInt(_modelMaxTokensKey) ?? 2048,
      topP: _prefs.getDouble(_modelTopPKey) ?? 0.9,
      topK: _prefs.getInt(_modelTopKKey) ?? 40,
      contextLength: _prefs.getInt(_modelContextLengthKey) ?? 4096,
    );
  }
}

class ModelSettings {
  final String modelId;
  final double temperature;
  final int maxTokens;
  final double topP;
  final int topK;
  final int contextLength;

  ModelSettings({
    required this.modelId,
    required this.temperature,
    required this.maxTokens,
    required this.topP,
    required this.topK,
    required this.contextLength,
  });
}
