// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get friendlyName => '中文';

  @override
  String get localeTitle => '区域';

  @override
  String get defaultLocale => '默认区域';

  @override
  String get loading => '加载中...';

  @override
  String get loadModel => '加载模型';

  @override
  String get downloadModel => '下载模型';

  @override
  String get noModelSelected => '未选择模型';

  @override
  String get noModelLoaded => '未加载模型';

  @override
  String get localModels => '本地模型';

  @override
  String get size => '大小';

  @override
  String get parameters => '参数';

  @override
  String get delete => '删除';

  @override
  String get select => '选择';

  @override
  String get import => '导入';

  @override
  String get export => '导出';

  @override
  String get edit => '编辑';

  @override
  String get regenerate => '重新生成';

  @override
  String get chatsTitle => '聊天';

  @override
  String get newChat => '新聊天';

  @override
  String get anErrorOccurred => '发生错误';

  @override
  String get errorTitle => '错误';

  @override
  String get key => '键';

  @override
  String get value => '值';

  @override
  String get ok => '确定';

  @override
  String get done => '完成';

  @override
  String get close => '关闭';

  @override
  String get save => '保存';

  @override
  String saveLabel(String label) {
    return '保存 $label';
  }

  @override
  String get selectTag => '选择标签';

  @override
  String get next => '下一步';

  @override
  String get previous => '上一步';

  @override
  String get contentShared => '内容已分享';

  @override
  String get setUserImage => '设置用户头像';

  @override
  String get setAssistantImage => '设置助手头像';

  @override
  String get loadUserImage => '加载用户头像';

  @override
  String get loadAssistantImage => '加载助手头像';

  @override
  String get userName => '用户名';

  @override
  String get assistantName => '助手名称';

  @override
  String get user => '用户';

  @override
  String get assistant => '助手';

  @override
  String get cancel => '取消';

  @override
  String get aiEcosystem => 'AI 生态系统';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Llama CPP 模型';

  @override
  String get remoteModel => '远程模型';

  @override
  String get refreshRemoteModels => '刷新远程模型';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => '搜索本地网络';

  @override
  String get localNetworkSearchTitle => '本地网络搜索';

  @override
  String get localNetworkSearchContent => '此功能需要额外的权限来搜索本地网络中的 Ollama 实例。';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => '模型参数';

  @override
  String get addParameter => '添加参数';

  @override
  String get removeParameter => '删除参数';

  @override
  String get saveParameters => '保存参数';

  @override
  String get importParameters => '导入参数';

  @override
  String get exportParameters => '导出参数';

  @override
  String get selectAiEcosystem => '选择 AI 生态系统';

  @override
  String get selectRemoteModel => '选择远程模型';

  @override
  String get selectThemeMode => '选择应用主题模式';

  @override
  String get themeMode => '主题模式';

  @override
  String get themeModeSystem => '系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get themeSeedColor => '主题种子颜色';

  @override
  String get editMessage => '编辑消息';

  @override
  String get settingsTitle => '设置';

  @override
  String aiSettings(String aiControllerType) {
    return '$aiControllerType 设置';
  }

  @override
  String get userSettings => '用户设置';

  @override
  String get assistantSettings => '助手设置';

  @override
  String get systemSettings => '系统设置';

  @override
  String get systemPrompt => '系统提示词';

  @override
  String get clearChats => '清空聊天';

  @override
  String get resetSettings => '重置设置';

  @override
  String get clearCache => '清除缓存';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutContent => 'Maid 是一款跨平台、开源免费应用，可本地运行 llama.cpp 模型，并支持远程连接 Ollama、Mistral、Google Gemini 和 OpenAI 模型。Maid 兼容 Sillytavern 角色卡，让您能与喜爱的角色互动。Maid 可直接从 Hugging Face 下载精选模型。Maid 遵循 MIT 许可证分发，并不提供任何明示或暗示的担保。Maid 与 Hugging Face、Meta (Facebook)、MistralAI、OpenAI、Google、Microsoft 或其他提供兼容模型的公司无关。';

  @override
  String get leadMaintainer => '主要维护者';

  @override
  String get apiKey => 'API 密钥';

  @override
  String get baseUrl => '基础 URL';

  @override
  String get clearPrompt => '清除提示词';

  @override
  String get submitPrompt => '提交提示词';

  @override
  String get stopPrompt => '停止提示词';

  @override
  String get typeMessage => '输入消息...';

  @override
  String get code => '代码';

  @override
  String copyLabel(String label) {
    return '复制 $label';
  }

  @override
  String labelCopied(String label) {
    return '$label 已复制到剪贴板！';
  }

  @override
  String get debugTitle => '调试';
}
