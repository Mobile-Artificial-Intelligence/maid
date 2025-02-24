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
  String get loading => '加载中...';

  @override
  String get loadModel => '加载模型';

  @override
  String get delete => '删除';

  @override
  String get chatsTitle => '聊天';

  @override
  String get anErrorOccurred => '发生了一个错误';

  @override
  String get errorTitle => '错误';

  @override
  String get ok => '确定';

  @override
  String get contentShared => '内容已分享';

  @override
  String get setUserImage => '设置用户图像';

  @override
  String get setAssistantImage => '设置助手图像';

  @override
  String get cancel => '取消';

  @override
  String get aiEcosystem => 'AI生态系统';

  @override
  String get selectAiEcosystem => '选择AI生态系统';

  @override
  String get selectOverrideType => '选择覆盖类型';

  @override
  String get overrideTypeString => '字符串';

  @override
  String get overrideTypeInteger => '整数';

  @override
  String get overrideTypeDouble => '双精度';

  @override
  String get overrideTypeBoolean => '布尔值';

  @override
  String get settingsTitle => '设置';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutContent => '女仆是一个跨平台的免费开源应用程序，用于本地与llama.cpp模型进行交互，远程与Ollama、Mistral、Google Gemini和OpenAI模型进行交互。女仆支持sillytavern角色卡，让您与所有喜欢的角色互动。女仆支持直接从huggingface下载应用内的精选模型列表。女仆根据MIT许可证分发，不提供任何明示或暗示的任何形式的保证。女仆与Huggingface、Meta（Facebook）、MistralAi、OpenAI、Google、Microsoft或任何其他提供与此应用程序兼容的模型的公司无关。';

  @override
  String get leadMaintainer => '主要维护者';
}
