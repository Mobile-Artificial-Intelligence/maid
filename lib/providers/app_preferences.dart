import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  final AppSettingsService _settingsService = AppSettingsService();
  
  // Load saved settings on initialization
  Future<void> loadSavedSettings() async {
    final selectedModel = _settingsService.getSelectedModel();
    final modelParameters = _settingsService.getModelParameters();
    final selectedCharacter = _settingsService.getSelectedCharacter();
    final characterSettings = _settingsService.getCharacterSettings();

    if (selectedModel != null) {
      // Apply saved model selection
      currentModel = selectedModel;
    }

    if (modelParameters != null) {
      // Apply saved model parameters
      applyModelParameters(modelParameters);
    }

    // ... apply other settings as needed ...
    
    notifyListeners();
  }

  // Save settings when they change
  Future<void> updateModelSelection(String modelId) async {
    await _settingsService.saveSelectedModel(modelId);
    currentModel = modelId;
    notifyListeners();
  }

  Future<void> updateModelParameters(Map<String, dynamic> parameters) async {
    await _settingsService.saveModelParameters(parameters);
    // Apply parameters
    notifyListeners();
  }

  // ... other methods ...
}
