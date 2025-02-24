// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Maid';

  @override
  String get loading => 'Loading...';

  @override
  String get loadModel => 'Load Model';

  @override
  String get noModelSelected => 'No Model Selected';

  @override
  String get delete => 'Delete';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get errorTitle => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get contentShared => 'Content Shared';

  @override
  String get setUserImage => 'Set User Image';

  @override
  String get setAssistantImage => 'Set Assistant Image';

  @override
  String get cancel => 'Cancel';

  @override
  String get aiEcosystem => 'AI Ecosystem';

  @override
  String get selectAiEcosystem => 'Select AI Ecosystem';

  @override
  String get selectOverrideType => 'Select Override Type';

  @override
  String get selectRemoteModel => 'Select Remote Model';

  @override
  String get overrideTypeString => 'String';

  @override
  String get overrideTypeInteger => 'Integer';

  @override
  String get overrideTypeDouble => 'Double';

  @override
  String get overrideTypeBoolean => 'Bool';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutContent => 'Maid is an cross-platform free and open source application for interfacing with llama.cpp models locally, and remotely with Ollama, Mistral, Google Gemini and OpenAI models remotely. Maid supports sillytavern character cards to allow you to interact with all your favorite characters. Maid supports downloading a curated list of Models in-app directly from huggingface. Maid is distributed under the MIT licence and is provided without warrenty of any kind, express or implied. Maid is not affiliated with Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft or any other company providing a model compatible with this application.';

  @override
  String get leadMaintainer => 'Lead Maintainer';
}
