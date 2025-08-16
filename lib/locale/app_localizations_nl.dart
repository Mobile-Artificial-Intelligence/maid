// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get friendlyName => 'Nederlands';

  @override
  String get localeTitle => 'Taal';

  @override
  String get defaultLocale => 'Standaardtaal';

  @override
  String get loading => 'Laden...';

  @override
  String get loadModel => 'Model laden';

  @override
  String get downloadModel => 'Model downloaden';

  @override
  String get noModelSelected => 'Geen model geselecteerd';

  @override
  String get noModelLoaded => 'Geen model geladen';

  @override
  String get localModels => 'Lokale modellen';

  @override
  String get size => 'Grootte';

  @override
  String get parameters => 'Parameters';

  @override
  String get delete => 'Verwijderen';

  @override
  String get select => 'Selecteren';

  @override
  String get import => 'Importeren';

  @override
  String get export => 'Exporteren';

  @override
  String get edit => 'Bewerken';

  @override
  String get regenerate => 'Opnieuw genereren';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get newChat => 'Nieuwe chat';

  @override
  String get anErrorOccurred => 'Er is een fout opgetreden';

  @override
  String get errorTitle => 'Fout';

  @override
  String get key => 'Sleutel';

  @override
  String get value => 'Waarde';

  @override
  String get ok => 'OK';

  @override
  String get proceed => 'Doorgaan';

  @override
  String get done => 'Klaar';

  @override
  String get close => 'Sluiten';

  @override
  String get save => 'Opslaan';

  @override
  String saveLabel(String label) {
    return 'Opslaan $label';
  }

  @override
  String get selectTag => 'Tag selecteren';

  @override
  String get next => 'Volgende';

  @override
  String get previous => 'Vorige';

  @override
  String get contentShared => 'Inhoud gedeeld';

  @override
  String get setUserImage => 'Gebruikersafbeelding instellen';

  @override
  String get setAssistantImage => 'Assistentafbeelding instellen';

  @override
  String get loadUserImage => 'Gebruikersafbeelding laden';

  @override
  String get loadAssistantImage => 'Assistentafbeelding laden';

  @override
  String get userName => 'Gebruikersnaam';

  @override
  String get assistantName => 'Assistentnaam';

  @override
  String get user => 'Gebruiker';

  @override
  String get assistant => 'Assistent';

  @override
  String get cancel => 'Annuleren';

  @override
  String get aiEcosystem => 'AI-ecosysteem';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Llama CPP-model';

  @override
  String get remoteModel => 'Extern model';

  @override
  String get refreshRemoteModels => 'Externe modellen vernieuwen';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Zoek lokaal netwerk';

  @override
  String get localNetworkSearchTitle => 'Zoeken in lokaal netwerk';

  @override
  String get localNetworkSearchContent =>
      'Deze functie vereist extra machtigingen om Ollama-instanties in uw lokale netwerk te zoeken.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get azureOpenAI => 'Azure OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => 'Modelparameters';

  @override
  String get addParameter => 'Parameter toevoegen';

  @override
  String get removeParameter => 'Parameter verwijderen';

  @override
  String get saveParameters => 'Parameters opslaan';

  @override
  String get importParameters => 'Parameters importeren';

  @override
  String get exportParameters => 'Parameters exporteren';

  @override
  String get selectAiEcosystem => 'AI-ecosysteem selecteren';

  @override
  String get selectRemoteModel => 'Extern model selecteren';

  @override
  String get selectThemeMode => 'App-thema selecteren';

  @override
  String get themeMode => 'Themamodus';

  @override
  String get themeModeSystem => 'Systeem';

  @override
  String get themeModeLight => 'Licht';

  @override
  String get themeModeDark => 'Donker';

  @override
  String get themeSeedColor => 'Thema basiskleur';

  @override
  String get editMessage => 'Bericht bewerken';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String aiSettings(String aiType) {
    return '$aiType-instellingen';
  }

  @override
  String get userSettings => 'Gebruikersinstellingen';

  @override
  String get assistantSettings => 'Assistentinstellingen';

  @override
  String get systemSettings => 'Systeeminstellingen';

  @override
  String get systemPrompt => 'Systeemprompt';

  @override
  String get clearChats => 'Chats wissen';

  @override
  String get resetSettings => 'Instellingen resetten';

  @override
  String get clearCache => 'Cache wissen';

  @override
  String get aboutTitle => 'Over';

  @override
  String get aboutContent =>
      'Maid is een gratis en open-source cross-platform applicatie voor het lokaal gebruiken van llama.cpp-modellen en het op afstand gebruiken van Ollama-, Mistral- en OpenAI-modellen. Maid ondersteunt Sillytavern-karakterkaarten, zodat je met je favoriete karakters kunt communiceren. Maid biedt de mogelijkheid om een lijst met geselecteerde modellen rechtstreeks vanuit de app te downloaden via Hugging Face. Maid wordt gedistribueerd onder de MIT-licentie en wordt geleverd zonder enige garantie, expliciet of impliciet. Maid is niet verbonden met Hugging Face, Meta (Facebook), MistralAI, OpenAI, Google, Microsoft of andere bedrijven die een compatibel model aanbieden.';

  @override
  String get leadMaintainer => 'Hoofdonderhouder';

  @override
  String get apiKey => 'API-sleutel';

  @override
  String get baseUrl => 'Basis-URL';

  @override
  String get scrollToRecent => 'Scroll naar recent';

  @override
  String get clearPrompt => 'Prompt wissen';

  @override
  String get submitPrompt => 'Prompt indienen';

  @override
  String get stopPrompt => 'Prompt stoppen';

  @override
  String get typeMessage => 'Typ een bericht...';

  @override
  String get code => 'Code';

  @override
  String copyLabel(String label) {
    return 'Kopieer $label';
  }

  @override
  String labelCopied(String label) {
    return '$label gekopieerd naar klembord!';
  }

  @override
  String get debugTitle => 'Debug';

  @override
  String get warning => 'Waarschuwing';

  @override
  String get nsfwWarning =>
      'Dit model is opzettelijk ontworpen om NSFW-inhoud te genereren. Dit kan expliciete seksuele of gewelddadige inhoud omvatten met betrekking tot marteling, verkrachting, moord en/of seksueel afwijkend gedrag. Als je gevoelig bent voor dergelijke onderwerpen, of als de bespreking van dergelijke onderwerpen in strijd is met de lokale wetgeving, GA NIET VERDER.';

  @override
  String get login => 'Inloggen';

  @override
  String get logout => 'Uitloggen';

  @override
  String get register => 'Registreren';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Wachtwoord';

  @override
  String get confirmPassword => 'Bevestig wachtwoord';

  @override
  String get resetCode => 'Resetcode';

  @override
  String get resetCodeSent => 'Een resetcode is naar je e-mail gestuurd.';

  @override
  String get sendResetCode => 'Resetcode verzenden';

  @override
  String get sendAgain => 'Opnieuw verzenden';

  @override
  String get required => 'Vereist';

  @override
  String get invalidEmail => 'Voer een geldig e-mailadres in';

  @override
  String get invalidUserName =>
      'Moet 3-24 tekens bevatten, alfanumeriek of een underscore';

  @override
  String get invalidPasswordLength => 'Minimaal 8 tekens';

  @override
  String get invalidPassword =>
      'Inclusief hoofdletters, kleine letters, cijfers en symbolen';

  @override
  String get passwordNoMatch => 'Wachtwoorden komen niet overeen';

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String get resetPassword => 'Wachtwoord resetten';

  @override
  String get backToLogin => 'Terug naar inloggen';

  @override
  String get alreadyHaveAccount => 'Ik heb al een account';

  @override
  String get success => 'Succes';

  @override
  String get registrationSuccess => 'Registratie succesvol';

  @override
  String get resetSuccess => 'Je wachtwoord is succesvol gereset.';

  @override
  String get emailVerify => 'Controleer je e-mail voor verificatie.';
}
