import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'locale/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @localeTitle.
  ///
  /// In en, this message translates to:
  /// **'Locale'**
  String get localeTitle;

  /// No description provided for @defaultLocale.
  ///
  /// In en, this message translates to:
  /// **'Default Locale'**
  String get defaultLocale;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadModel.
  ///
  /// In en, this message translates to:
  /// **'Load Model'**
  String get loadModel;

  /// No description provided for @noModelSelected.
  ///
  /// In en, this message translates to:
  /// **'No Model Selected'**
  String get noModelSelected;

  /// No description provided for @noModelLoaded.
  ///
  /// In en, this message translates to:
  /// **'No Model Loaded'**
  String get noModelLoaded;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @key.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get key;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @contentShared.
  ///
  /// In en, this message translates to:
  /// **'Content Shared'**
  String get contentShared;

  /// No description provided for @setUserImage.
  ///
  /// In en, this message translates to:
  /// **'Set User Image'**
  String get setUserImage;

  /// No description provided for @setAssistantImage.
  ///
  /// In en, this message translates to:
  /// **'Set Assistant Image'**
  String get setAssistantImage;

  /// No description provided for @loadUserImage.
  ///
  /// In en, this message translates to:
  /// **'Load User Image'**
  String get loadUserImage;

  /// No description provided for @loadAssistantImage.
  ///
  /// In en, this message translates to:
  /// **'Load Assistant Image'**
  String get loadAssistantImage;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @assistantName.
  ///
  /// In en, this message translates to:
  /// **'Assistant Name'**
  String get assistantName;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistant;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @aiEcosystem.
  ///
  /// In en, this message translates to:
  /// **'AI Ecosystem'**
  String get aiEcosystem;

  /// No description provided for @llamaCpp.
  ///
  /// In en, this message translates to:
  /// **'Llama CPP'**
  String get llamaCpp;

  /// No description provided for @llamaCppModel.
  ///
  /// In en, this message translates to:
  /// **'Llama CPP Model'**
  String get llamaCppModel;

  /// No description provided for @remoteModel.
  ///
  /// In en, this message translates to:
  /// **'Remote Model'**
  String get remoteModel;

  /// No description provided for @refreshRemoteModels.
  ///
  /// In en, this message translates to:
  /// **'Refresh Remote Models'**
  String get refreshRemoteModels;

  /// No description provided for @ollama.
  ///
  /// In en, this message translates to:
  /// **'Ollama'**
  String get ollama;

  /// No description provided for @searchLocalNetwork.
  ///
  /// In en, this message translates to:
  /// **'Search Local Network'**
  String get searchLocalNetwork;

  /// No description provided for @localNetworkSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Network Search'**
  String get localNetworkSearchTitle;

  /// No description provided for @localNetworkSearchContent.
  ///
  /// In en, this message translates to:
  /// **'\'This feature requires additional permissions to search your local network for Ollama instances.'**
  String get localNetworkSearchContent;

  /// No description provided for @openAI.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get openAI;

  /// No description provided for @mistral.
  ///
  /// In en, this message translates to:
  /// **'Mistral'**
  String get mistral;

  /// No description provided for @selectAiEcosystem.
  ///
  /// In en, this message translates to:
  /// **'Select AI Ecosystem'**
  String get selectAiEcosystem;

  /// No description provided for @selectOverrideType.
  ///
  /// In en, this message translates to:
  /// **'Select Override Type'**
  String get selectOverrideType;

  /// No description provided for @selectRemoteModel.
  ///
  /// In en, this message translates to:
  /// **'Select Remote Model'**
  String get selectRemoteModel;

  /// No description provided for @selectThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Select App Theme Mode'**
  String get selectThemeMode;

  /// No description provided for @overrideTypeString.
  ///
  /// In en, this message translates to:
  /// **'String'**
  String get overrideTypeString;

  /// No description provided for @overrideTypeInteger.
  ///
  /// In en, this message translates to:
  /// **'Integer'**
  String get overrideTypeInteger;

  /// No description provided for @overrideTypeDouble.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get overrideTypeDouble;

  /// No description provided for @overrideTypeBoolean.
  ///
  /// In en, this message translates to:
  /// **'Bool'**
  String get overrideTypeBoolean;

  /// No description provided for @inferanceOverrides.
  ///
  /// In en, this message translates to:
  /// **'Inference Overrides'**
  String get inferanceOverrides;

  /// No description provided for @addOverride.
  ///
  /// In en, this message translates to:
  /// **'Add Override'**
  String get addOverride;

  /// No description provided for @saveOverride.
  ///
  /// In en, this message translates to:
  /// **'Save Override'**
  String get saveOverride;

  /// No description provided for @deleteOverride.
  ///
  /// In en, this message translates to:
  /// **'Delete Override'**
  String get deleteOverride;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeSeedColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Seed Color'**
  String get themeSeedColor;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings for {aiControllerType}
  ///
  /// In en, this message translates to:
  /// **'{aiControllerType} Settings'**
  String aiSettings(String aiControllerType);

  /// No description provided for @userSettings.
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get userSettings;

  /// No description provided for @assistantSettings.
  ///
  /// In en, this message translates to:
  /// **'Assistant Settings'**
  String get assistantSettings;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @systemPrompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get systemPrompt;

  /// No description provided for @clearChats.
  ///
  /// In en, this message translates to:
  /// **'Clear Chats'**
  String get clearChats;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'Maid is an cross-platform free and open source application for interfacing with llama.cpp models locally, and remotely with Ollama, Mistral, Google Gemini and OpenAI models remotely. Maid supports sillytavern character cards to allow you to interact with all your favorite characters. Maid supports downloading a curated list of Models in-app directly from huggingface. Maid is distributed under the MIT licence and is provided without warrenty of any kind, express or implied. Maid is not affiliated with Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft or any other company providing a model compatible with this application.'**
  String get aboutContent;

  /// No description provided for @leadMaintainer.
  ///
  /// In en, this message translates to:
  /// **'Lead Maintainer'**
  String get leadMaintainer;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @clearPrompt.
  ///
  /// In en, this message translates to:
  /// **'Clear Prompt'**
  String get clearPrompt;

  /// No description provided for @submitPrompt.
  ///
  /// In en, this message translates to:
  /// **'Submit Prompt'**
  String get submitPrompt;

  /// No description provided for @stopPrompt.
  ///
  /// In en, this message translates to:
  /// **'Stop Prompt'**
  String get stopPrompt;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Copy the {label} to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy {label}'**
  String copyLabel(String label);

  /// {label} copied to clipboard!
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard!'**
  String labelCopied(String label);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr', 'ja', 'ko', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'ru': return AppLocalizationsRu();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
