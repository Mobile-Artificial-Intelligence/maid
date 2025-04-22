// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get friendlyName => 'English';

  @override
  String get localeTitle => 'Locale';

  @override
  String get defaultLocale => 'Default Locale';

  @override
  String get loading => 'Loading...';

  @override
  String get loadModel => 'Load Model';

  @override
  String get downloadModel => 'Download Model';

  @override
  String get noModelSelected => 'No Model Selected';

  @override
  String get noModelLoaded => 'No Model Loaded';

  @override
  String get localModels => 'Local Models';

  @override
  String get size => 'Size';

  @override
  String get parameters => 'Parameters';

  @override
  String get delete => 'Delete';

  @override
  String get select => 'Select';

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get edit => 'Edit';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get newChat => 'New Chat';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get errorTitle => 'Error';

  @override
  String get key => 'Key';

  @override
  String get value => 'Value';

  @override
  String get ok => 'OK';

  @override
  String get proceed => 'Proceed';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String saveLabel(String label) {
    return 'Save $label';
  }

  @override
  String get selectTag => 'Select Tag';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get contentShared => 'Content Shared';

  @override
  String get setUserImage => 'Set User Image';

  @override
  String get setAssistantImage => 'Set Assistant Image';

  @override
  String get loadUserImage => 'Load User Image';

  @override
  String get loadAssistantImage => 'Load Assistant Image';

  @override
  String get userName => 'User Name';

  @override
  String get assistantName => 'Assistant Name';

  @override
  String get user => 'User';

  @override
  String get assistant => 'Assistant';

  @override
  String get cancel => 'Cancel';

  @override
  String get aiEcosystem => 'AI Ecosystem';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Llama CPP Model';

  @override
  String get remoteModel => 'Remote Model';

  @override
  String get refreshRemoteModels => 'Refresh Remote Models';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Search Local Network';

  @override
  String get localNetworkSearchTitle => 'Local Network Search';

  @override
  String get localNetworkSearchContent => 'This feature requires additional permissions to search your local network for Ollama instances.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => 'Model Parameters';

  @override
  String get addParameter => 'Add Parameter';

  @override
  String get removeParameter => 'Remove Parameter';

  @override
  String get saveParameters => 'Save Parameters';

  @override
  String get importParameters => 'Import Parameters';

  @override
  String get exportParameters => 'Export Parameters';

  @override
  String get selectAiEcosystem => 'Select AI Ecosystem';

  @override
  String get selectRemoteModel => 'Select Remote Model';

  @override
  String get selectThemeMode => 'Select App Theme Mode';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeSeedColor => 'Theme Seed Color';

  @override
  String get editMessage => 'Edit Message';

  @override
  String get settingsTitle => 'Settings';

  @override
  String aiSettings(String aiType) {
    return '$aiType Settings';
  }

  @override
  String get userSettings => 'User Settings';

  @override
  String get assistantSettings => 'Assistant Settings';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get systemPrompt => 'System Prompt';

  @override
  String get clearChats => 'Clear Chats';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutContent => 'Maid is a cross-platform free and open source application for interfacing with llama.cpp models locally, and remotely with Ollama, Mistral, and OpenAI models remotely. Maid supports sillytavern character cards to allow you to interact with all your favorite characters. Maid supports downloading a curated list of Models in-app directly from huggingface. Maid is distributed under the MIT licence and is provided without warrenty of any kind, express or implied. Maid is not affiliated with Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft or any other company providing a model compatible with this application.';

  @override
  String get leadMaintainer => 'Lead Maintainer';

  @override
  String get apiKey => 'API Key';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get scrollToRecent => 'Scroll to Recent';

  @override
  String get clearPrompt => 'Clear Prompt';

  @override
  String get submitPrompt => 'Submit Prompt';

  @override
  String get stopPrompt => 'Stop Prompt';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get code => 'Code';

  @override
  String copyLabel(String label) {
    return 'Copy $label';
  }

  @override
  String labelCopied(String label) {
    return '$label copied to clipboard!';
  }

  @override
  String get debugTitle => 'Debug';

  @override
  String get warning => 'Warning';

  @override
  String get nsfwWarning => 'This model is intentionally designed to produce NSFW content. This may include explicit sexual or violent content involving torture, rape, murder and / or sexually deviant behaviour. If you are sensitive to such topics, or the discussion of such topics violates local laws, DO NOT PROCEED.';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get resetCode => 'Reset Code';

  @override
  String get resetCodeSent => 'A reset code has been sent to your email.';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get sendAgain => 'Send Again';

  @override
  String get required => 'Required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get invalidUserName => 'Must be 3-24 characters, alphanumeric or underscore';

  @override
  String get invalidPasswordLength => 'Minimum 8 characters';

  @override
  String get invalidPassword => 'Include upper, lower, number, and symbol';

  @override
  String get passwordNoMatch => 'Passwords do not match';

  @override
  String get createAccount => 'Create an account';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get success => 'Success';

  @override
  String get registrationSuccess => 'Registration Successful';

  @override
  String get resetSuccess => 'Your password has been reset successfully.';

  @override
  String get emailVerify => 'Please check your email for verification.';
}
