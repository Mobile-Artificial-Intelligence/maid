// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '女仆';

  @override
  String get settingsTitle => '设置';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutContent => '女仆是一个跨平台的免费开源应用程序，用于本地与llama.cpp模型进行交互，远程与Ollama、Mistral、Google Gemini和OpenAI模型进行交互。女仆支持sillytavern角色卡，让您与所有喜欢的角色互动。女仆支持直接从huggingface下载应用内的精选模型列表。女仆根据MIT许可证分发，不提供任何明示或暗示的任何形式的保证。女仆与Huggingface、Meta（Facebook）、MistralAi、OpenAI、Google、Microsoft或任何其他提供与此应用程序兼容的模型的公司无关。';

  @override
  String get leadMaintainer => '主要维护者';
}
