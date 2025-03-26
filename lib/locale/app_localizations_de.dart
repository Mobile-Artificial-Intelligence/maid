// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get friendlyName => 'Deutsch';

  @override
  String get localeTitle => 'Sprache';

  @override
  String get defaultLocale => 'Standardsprache';

  @override
  String get loading => 'Laden...';

  @override
  String get loadModel => 'Modell laden';

  @override
  String get noModelSelected => 'Kein Modell ausgewählt';

  @override
  String get noModelLoaded => 'Kein Modell geladen';

  @override
  String get delete => 'Löschen';

  @override
  String get import => 'Importieren';

  @override
  String get export => 'Exportieren';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get regenerate => 'Neu generieren';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String get anErrorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get errorTitle => 'Fehler';

  @override
  String get key => 'Schlüssel';

  @override
  String get value => 'Wert';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Fertig';

  @override
  String get close => 'Schließen';

  @override
  String save(String label) {
    return 'Speichern $label';
  }

  @override
  String get next => 'Weiter';

  @override
  String get previous => 'Zurück';

  @override
  String get contentShared => 'Inhalt geteilt';

  @override
  String get setUserImage => 'Benutzerbild festlegen';

  @override
  String get setAssistantImage => 'Assistentenbild festlegen';

  @override
  String get loadUserImage => 'Benutzerbild laden';

  @override
  String get loadAssistantImage => 'Assistentenbild laden';

  @override
  String get userName => 'Benutzername';

  @override
  String get assistantName => 'Assistentenname';

  @override
  String get user => 'Benutzer';

  @override
  String get assistant => 'Assistent';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get aiEcosystem => 'KI-Ökosystem';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Llama CPP Modell';

  @override
  String get remoteModel => 'Remote-Modell';

  @override
  String get refreshRemoteModels => 'Remote-Modelle aktualisieren';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Lokales Netzwerk durchsuchen';

  @override
  String get localNetworkSearchTitle => 'Suche im lokalen Netzwerk';

  @override
  String get localNetworkSearchContent => 'Diese Funktion benötigt zusätzliche Berechtigungen, um Ihr lokales Netzwerk nach Ollama-Instanzen zu durchsuchen.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get googleGemini => 'Google Gemini';

  @override
  String get selectAiEcosystem => 'KI-Ökosystem auswählen';

  @override
  String get selectOverrideType => 'Überschreibungstyp auswählen';

  @override
  String get selectRemoteModel => 'Remote-Modell auswählen';

  @override
  String get selectThemeMode => 'App-Designmodus auswählen';

  @override
  String get inferanceOverrides => 'Inferenz-Überschreibungen';

  @override
  String get addOverride => 'Überschreibung hinzufügen';

  @override
  String get saveOverride => 'Überschreibung speichern';

  @override
  String get deleteOverride => 'Überschreibung löschen';

  @override
  String get themeMode => 'Designmodus';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get themeSeedColor => 'Design-Farbton';

  @override
  String get editMessage => 'Nachricht bearbeiten';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String aiSettings(String aiControllerType) {
    return '$aiControllerType Einstellungen';
  }

  @override
  String get userSettings => 'Benutzereinstellungen';

  @override
  String get assistantSettings => 'Assistenteneinstellungen';

  @override
  String get systemSettings => 'Systemeinstellungen';

  @override
  String get systemPrompt => 'System-Prompt';

  @override
  String get clearChats => 'Chats löschen';

  @override
  String get resetSettings => 'Einstellungen zurücksetzen';

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutContent => 'Maid ist eine plattformübergreifende, kostenlose und Open-Source-Anwendung zur Nutzung von llama.cpp-Modellen lokal und für die Fernverwendung mit Ollama-, Mistral- und OpenAI-Modellen. Maid unterstützt SillyTavern-Charakterkarten, sodass Sie mit Ihren Lieblingscharakteren interagieren können. Maid ermöglicht den direkten Download einer kuratierten Liste von Modellen aus Hugging Face. Maid wird unter der MIT-Lizenz vertrieben und ohne jegliche Gewährleistung bereitgestellt, weder ausdrücklich noch impliziert. Maid ist nicht mit Hugging Face, Meta (Facebook), MistralAI, OpenAI, Google, Microsoft oder anderen Unternehmen verbunden, die mit dieser Anwendung kompatible Modelle anbieten.';

  @override
  String get leadMaintainer => 'Hauptbetreuer';

  @override
  String get apiKey => 'API-Schlüssel';

  @override
  String get baseUrl => 'Basis-URL';

  @override
  String get clearPrompt => 'Prompt löschen';

  @override
  String get submitPrompt => 'Prompt senden';

  @override
  String get stopPrompt => 'Prompt stoppen';

  @override
  String get typeMessage => 'Nachricht eingeben...';

  @override
  String get code => 'Code';

  @override
  String copyLabel(String label) {
    return '$label kopieren';
  }

  @override
  String labelCopied(String label) {
    return '$label in die Zwischenablage kopiert!';
  }
}
