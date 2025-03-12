// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get friendlyName => '日本語';

  @override
  String get localeTitle => 'ロケール';

  @override
  String get defaultLocale => 'デフォルトロケール';

  @override
  String get loading => '読み込み中...';

  @override
  String get loadModel => 'モデルを読み込む';

  @override
  String get noModelSelected => 'モデルが選択されていません';

  @override
  String get noModelLoaded => 'モデルが読み込まれていません';

  @override
  String get delete => '削除';

  @override
  String get import => 'インポート';

  @override
  String get export => 'エクスポート';

  @override
  String get edit => '編集';

  @override
  String get regenerate => '再生成';

  @override
  String get chatsTitle => 'チャット';

  @override
  String get newChat => '新しいチャット';

  @override
  String get anErrorOccurred => 'エラーが発生しました';

  @override
  String get errorTitle => 'エラー';

  @override
  String get key => 'キー';

  @override
  String get value => '値';

  @override
  String get ok => 'OK';

  @override
  String get done => '完了';

  @override
  String get close => '閉じる';

  @override
  String save(String label) {
    return '$label を保存';
  }

  @override
  String get next => '次へ';

  @override
  String get previous => '前へ';

  @override
  String get contentShared => 'コンテンツが共有されました';

  @override
  String get setUserImage => 'ユーザー画像を設定';

  @override
  String get setAssistantImage => 'アシスタント画像を設定';

  @override
  String get loadUserImage => 'ユーザー画像を読み込む';

  @override
  String get loadAssistantImage => 'アシスタント画像を読み込む';

  @override
  String get userName => 'ユーザー名';

  @override
  String get assistantName => 'アシスタント名';

  @override
  String get user => 'ユーザー';

  @override
  String get assistant => 'アシスタント';

  @override
  String get cancel => 'キャンセル';

  @override
  String get aiEcosystem => 'AIエコシステム';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Llama CPPモデル';

  @override
  String get remoteModel => 'リモートモデル';

  @override
  String get refreshRemoteModels => 'リモートモデルを更新';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'ローカルネットワークを検索';

  @override
  String get localNetworkSearchTitle => 'ローカルネットワーク検索';

  @override
  String get localNetworkSearchContent => 'この機能は、ローカルネットワーク上のOllamaインスタンスを検索するための追加の権限を必要とします。';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get selectAiEcosystem => 'AIエコシステムを選択';

  @override
  String get selectOverrideType => 'オーバーライドの種類を選択';

  @override
  String get selectRemoteModel => 'リモートモデルを選択';

  @override
  String get selectThemeMode => 'アプリのテーマモードを選択';

  @override
  String get overrideTypeString => '文字列';

  @override
  String get overrideTypeInteger => '整数';

  @override
  String get overrideTypeDouble => '小数';

  @override
  String get overrideTypeBoolean => 'ブール';

  @override
  String get inferanceOverrides => '推論オーバーライド';

  @override
  String get addOverride => 'オーバーライドを追加';

  @override
  String get saveOverride => 'オーバーライドを保存';

  @override
  String get deleteOverride => 'オーバーライドを削除';

  @override
  String get themeMode => 'テーマモード';

  @override
  String get themeModeSystem => 'システム';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get themeSeedColor => 'テーマの基調色';

  @override
  String get editMessage => 'メッセージを編集';

  @override
  String get settingsTitle => '設定';

  @override
  String aiSettings(String aiControllerType) {
    return '$aiControllerType の設定';
  }

  @override
  String get userSettings => 'ユーザー設定';

  @override
  String get assistantSettings => 'アシスタント設定';

  @override
  String get systemSettings => 'システム設定';

  @override
  String get systemPrompt => 'システムプロンプト';

  @override
  String get clearChats => 'チャットをクリア';

  @override
  String get resetSettings => '設定をリセット';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get aboutTitle => 'アプリについて';

  @override
  String get aboutContent => 'Maidは、ローカルのllama.cppモデル、およびリモートのOllama、Mistral、Google Gemini、OpenAIモデルとインターフェースするためのクロスプラットフォームの無料かつオープンソースのアプリケーションです。Maidは、SillyTavernのキャラクターカードをサポートしており、お気に入りのキャラクターと対話することができます。Maidは、Hugging Faceからモデルを直接アプリ内でダウンロードできる機能を提供しています。MaidはMITライセンスのもとで配布されており、明示的または暗示的な保証なしで提供されます。Maidは、Hugging Face、Meta (Facebook)、MistralAI、OpenAI、Google、Microsoft、またはこのアプリケーションと互換性のあるモデルを提供する他の企業とは提携していません。';

  @override
  String get leadMaintainer => 'リードメンテナー';

  @override
  String get apiKey => 'APIキー';

  @override
  String get baseUrl => 'ベースURL';

  @override
  String get clearPrompt => 'プロンプトをクリア';

  @override
  String get submitPrompt => 'プロンプトを送信';

  @override
  String get stopPrompt => 'プロンプトを停止';

  @override
  String get typeMessage => 'メッセージを入力...';

  @override
  String get code => 'コード';

  @override
  String copyLabel(String label) {
    return '$label をコピー';
  }

  @override
  String labelCopied(String label) {
    return '$label をクリップボードにコピーしました！';
  }
}
