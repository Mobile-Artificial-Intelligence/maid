enum LargeLanguageModelType { 
  none, 
  llamacpp, 
  openAI, 
  ollama, 
  mistralAI, 
  gemini 
}

extension LargeLanguageModelTypeExtension on LargeLanguageModelType {
  String get displayName {
    switch (this) {
      case LargeLanguageModelType.llamacpp:
        return '毕设-轻量大模型';
      case LargeLanguageModelType.ollama:
        return 'Ollama';
      case LargeLanguageModelType.openAI:
        return 'Open AI';
      case LargeLanguageModelType.mistralAI:
        return 'Mistral AI';
      case LargeLanguageModelType.gemini:
        return 'Gemini';
      default:
        return '';
    }
  }
}