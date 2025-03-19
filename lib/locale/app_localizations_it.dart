// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get friendlyName => 'Italiano';

  @override
  String get localeTitle => 'Lingua';

  @override
  String get defaultLocale => 'Lingua predefinita';

  @override
  String get loading => 'Caricamento...';

  @override
  String get loadModel => 'Carica modello';

  @override
  String get noModelSelected => 'Nessun modello selezionato';

  @override
  String get noModelLoaded => 'Nessun modello caricato';

  @override
  String get delete => 'Elimina';

  @override
  String get import => 'Importa';

  @override
  String get export => 'Esporta';

  @override
  String get edit => 'Modifica';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get chatsTitle => 'Chat';

  @override
  String get newChat => 'Nuova chat';

  @override
  String get anErrorOccurred => 'Si è verificato un errore';

  @override
  String get errorTitle => 'Errore';

  @override
  String get key => 'Chiave';

  @override
  String get value => 'Valore';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Fatto';

  @override
  String get close => 'Chiudi';

  @override
  String save(String label) {
    return 'Salva $label';
  }

  @override
  String get next => 'Prossimo';

  @override
  String get previous => 'Precedente';

  @override
  String get contentShared => 'Contenuto condiviso';

  @override
  String get setUserImage => 'Imposta immagine utente';

  @override
  String get setAssistantImage => 'Imposta immagine assistente';

  @override
  String get loadUserImage => 'Carica immagine utente';

  @override
  String get loadAssistantImage => 'Carica immagine assistente';

  @override
  String get userName => 'Nome utente';

  @override
  String get assistantName => 'Nome assistente';

  @override
  String get user => 'Utente';

  @override
  String get assistant => 'Assistente';

  @override
  String get cancel => 'Annulla';

  @override
  String get aiEcosystem => 'Ecosistema IA';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Modello Llama CPP';

  @override
  String get remoteModel => 'Modello remoto';

  @override
  String get refreshRemoteModels => 'Ricarica modelli remoti';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Cerca nella rete locale';

  @override
  String get localNetworkSearchTitle => 'Cerca nella rete locale';

  @override
  String get localNetworkSearchContent => 'Questa funzionalità richiede permessi aggiuntivi per cercare le istanze di Ollama nella rete locale.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get googleGemini => 'Google Gemini';

  @override
  String get selectAiEcosystem => 'Seleziona ecosistema IA';

  @override
  String get selectOverrideType => 'Seleziona tipo di override';

  @override
  String get selectRemoteModel => 'Seleziona modello remoto';

  @override
  String get selectThemeMode => 'Seleziona modalità tema dell\'app';

  @override
  String get overrideTypeString => 'Stringa';

  @override
  String get overrideTypeInteger => 'Intero';

  @override
  String get overrideTypeDouble => 'Decimale';

  @override
  String get overrideTypeBoolean => 'Booleano';

  @override
  String get inferanceOverrides => 'Override di inferenza';

  @override
  String get addOverride => 'Aggiungi override';

  @override
  String get saveOverride => 'Salva override';

  @override
  String get deleteOverride => 'Elimina override';

  @override
  String get themeMode => 'Modalità tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Chiaro';

  @override
  String get themeModeDark => 'Scuro';

  @override
  String get themeSeedColor => '\'Colore di base del tema';

  @override
  String get editMessage => 'Modifica messaggio';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String aiSettings(String aiControllerType) {
    return 'Impostazioni $aiControllerType';
  }

  @override
  String get userSettings => 'Impostazioni utente';

  @override
  String get assistantSettings => 'Impostazioni assistente';

  @override
  String get systemSettings => 'Impostazioni di sistema';

  @override
  String get systemPrompt => 'Prompt di sistema';

  @override
  String get clearChats => 'Svuota le chat';

  @override
  String get resetSettings => 'Ripristina impostazioni';

  @override
  String get clearCache => 'Svuota la cache';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get aboutContent => 'Maid è un\'applicazione multipiattaforma gratuita e open source per interfacciarsi localmente con i modelli di llama.cpp, e da remoto con i modelli di Ollama, Mistral e OpenAI. Maid supporta le schede dei personaggi di sillytavern per permetterti di interagire con tutti i tuoi personaggi preferiti. Maid consente di scaricare, direttamente dall\'app, una lista curata di modelli da huggingface. Maid è distribuito sotto la licenza MIT ed è fornito senza alcuna garanzia, esplicita o implicita. Maid non è affiliato con Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft o con qualsiasi altra azienda che fornisce un modello compatibile con questa applicazione.';

  @override
  String get leadMaintainer => 'Manutentore principale';

  @override
  String get apiKey => 'Chiave API';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get clearPrompt => 'Pulisci il prompt';

  @override
  String get submitPrompt => 'Invia il prompt';

  @override
  String get stopPrompt => 'Ferma il prompt';

  @override
  String get typeMessage => 'Scrivi un messaggio...';

  @override
  String get code => 'Codice';

  @override
  String copyLabel(String label) {
    return 'Copia $label';
  }

  @override
  String labelCopied(String label) {
    return '$label copiati negli appunti!';
  }
}
