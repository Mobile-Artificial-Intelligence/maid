// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh_TW`).
class AppLocalizationsZhTW extends AppLocalizations {
  AppLocalizationsZhTW([String locale = 'zh_TW']) : super(locale);

  @override
  String get friendlyName => '繁體中文';

  @override
  String get localeTitle => '區域';

  @override
  String get defaultLocale => '預設區域';

  @override
  String get loading => '載入中...';

  @override
  String get loadModel => '載入模型';

  @override
  String get downloadModel => '下載模型';

  @override
  String get noModelSelected => '未選擇模型';

  @override
  String get noModelLoaded => '未載入模型';

  @override
  String get localModels => '本地模型';

  @override
  String get size => '大小';

  @override
  String get parameters => '參數';

  @override
  String get delete => '刪除';

  @override
  String get select => '選擇';

  @override
  String get import => '導入';

  @override
  String get export => '導出';

  @override
  String get edit => '編輯';

  @override
  String get regenerate => '重新生成';

  @override
  String get chatsTitle => '聊天';

  @override
  String get newChat => '新聊天';

  @override
  String get anErrorOccurred => '發生錯誤';

  @override
  String get errorTitle => '錯誤';

  @override
  String get key => '鍵';

  @override
  String get value => '值';

  @override
  String get ok => '確定';

  @override
  String get proceed => '繼續';

  @override
  String get done => '完成';

  @override
  String get close => '關閉';

  @override
  String get save => '儲存';

  @override
  String saveLabel(String label) {
    return '儲存 $label';
  }

  @override
  String get selectTag => '選擇標籤';

  @override
  String get next => '下一步';

  @override
  String get previous => '上一步';

  @override
  String get contentShared => '內容已分享';

  @override
  String get setUserImage => '設定用戶頭像';

  @override
  String get setAssistantImage => '設定助手頭像';

  @override
  String get loadUserImage => '載入用戶頭像';

  @override
  String get loadAssistantImage => '載入助手頭像';

  @override
  String get userName => '用戶名';

  @override
  String get assistantName => '助手名稱';

  @override
  String get user => '用戶';

  @override
  String get assistant => '助手';

  @override
  String get cancel => '取消';

  @override
  String get aiEcosystem => 'AI 生態系統';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Llama CPP 模型';

  @override
  String get remoteModel => '遠端模型';

  @override
  String get refreshRemoteModels => '刷新遠端模型';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => '搜尋本地網路';

  @override
  String get localNetworkSearchTitle => '本地網路搜尋';

  @override
  String get localNetworkSearchContent => '此功能需要額外的權限來搜尋本地網路中的 Ollama 實例。';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => '模型參數';

  @override
  String get addParameter => '添加參數';

  @override
  String get removeParameter => '刪除參數';

  @override
  String get saveParameters => '儲存參數';

  @override
  String get importParameters => '導入參數';

  @override
  String get exportParameters => '導出參數';

  @override
  String get selectAiEcosystem => '選擇 AI 生態系統';

  @override
  String get selectRemoteModel => '選擇遠端模型';

  @override
  String get selectThemeMode => '選擇應用主題模式';

  @override
  String get themeMode => '主題模式';

  @override
  String get themeModeSystem => '系統';

  @override
  String get themeModeLight => '淺色';

  @override
  String get themeModeDark => '深色';

  @override
  String get themeSeedColor => '主題種子顏色';

  @override
  String get editMessage => '編輯訊息';

  @override
  String get settingsTitle => '設定';

  @override
  String aiSettings(String aiType) {
    return '$aiType 設定';
  }

  @override
  String get userSettings => '用戶設定';

  @override
  String get assistantSettings => '助手設定';

  @override
  String get systemSettings => '系統設定';

  @override
  String get systemPrompt => '系統提示詞';

  @override
  String get clearChats => '清空聊天';

  @override
  String get resetSettings => '重置設定';

  @override
  String get clearCache => '清除快取';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutContent => 'Maid 是一款跨平臺、開源免費應用，可本地運行 llama.cpp 模型，並支持遠端連接 Ollama、Mistral、Google Gemini 和 OpenAI 模型。Maid 兼容 Sillytavern 角色卡，讓您能與喜愛的角色互動。Maid 可直接從 Hugging Face 下載精選模型。Maid 遵循 MIT 許可證分發，並不提供任何明示或暗示的擔保。Maid 與 Hugging Face、Meta (Facebook)、MistralAI、OpenAI、Google、Microsoft 或其他提供兼容模型的公司無關。';

  @override
  String get leadMaintainer => '主要維護者';

  @override
  String get apiKey => 'API 密鑰';

  @override
  String get baseUrl => '基礎 URL';

  @override
  String get scrollToRecent => '滾動到最近的訊息';

  @override
  String get clearPrompt => '清除提示詞';

  @override
  String get submitPrompt => '提交提示詞';

  @override
  String get stopPrompt => '停止提示詞';

  @override
  String get typeMessage => '輸入訊息...';

  @override
  String get code => '程式';

  @override
  String copyLabel(String label) {
    return '複製 $label';
  }

  @override
  String labelCopied(String label) {
    return '$label 已複製到剪貼簿！';
  }

  @override
  String get debugTitle => '除錯';

  @override
  String get warning => '警告';

  @override
  String get nsfwWarning => '該模型被有意設計用於生成NSFW（不適宜公開）的內容。這可能包括涉及酷刑、強姦、謀殺和/或性變態行為的露骨性或暴力內容。如果您對這些話題較為敏感，或這些話題的討論違反了當地法律，請不要繼續。';

  @override
  String get login => '登錄';

  @override
  String get logout => '登出';

  @override
  String get register => '註冊';

  @override
  String get email => '電子郵件';

  @override
  String get password => '密碼';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get resetCode => '重置碼';

  @override
  String get resetCodeSent => '重置碼已發送至您的電子郵件。';

  @override
  String get sendResetCode => '發送重置碼';

  @override
  String get sendAgain => '再次發送';

  @override
  String get required => '必填';

  @override
  String get invalidEmail => '請輸入有效的電子郵件';

  @override
  String get invalidUserName => '必須為3-24個字符，字母數字或下劃線';

  @override
  String get invalidPasswordLength => '至少8個字符';

  @override
  String get invalidPassword => '需包含大寫字母、小寫字母、數字和符號';

  @override
  String get passwordNoMatch => '密碼不匹配';

  @override
  String get createAccount => '創建帳號';

  @override
  String get resetPassword => '重置密碼';

  @override
  String get backToLogin => '返回登錄';

  @override
  String get alreadyHaveAccount => '我已有帳號';

  @override
  String get success => '成功';

  @override
  String get registrationSuccess => '註冊成功';

  @override
  String get resetSuccess => '您的密碼已成功重置。';

  @override
  String get emailVerify => '請檢查您的電子郵件以進行驗證。';
}
