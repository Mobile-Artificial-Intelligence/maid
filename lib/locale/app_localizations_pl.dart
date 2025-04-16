// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get friendlyName => 'Polski';

  @override
  String get localeTitle => 'Język';

  @override
  String get defaultLocale => 'Domyślny język';

  @override
  String get loading => 'Ładowanie...';

  @override
  String get loadModel => 'Wczytaj model';

  @override
  String get downloadModel => 'Pobierz model';

  @override
  String get noModelSelected => 'Nie wybrano modelu';

  @override
  String get noModelLoaded => 'Nie wczytano modelu';

  @override
  String get localModels => 'Modele lokalne';

  @override
  String get size => 'Rozmiar';

  @override
  String get parameters => 'Parametry';

  @override
  String get delete => 'Usuń';

  @override
  String get select => 'Wybierz';

  @override
  String get import => 'Importuj';

  @override
  String get export => 'Eksportuj';

  @override
  String get edit => 'Edytuj';

  @override
  String get regenerate => 'Wygeneruj ponownie';

  @override
  String get chatsTitle => 'Czaty';

  @override
  String get newChat => 'Nowy czat';

  @override
  String get anErrorOccurred => 'Wystąpił błąd';

  @override
  String get errorTitle => 'Błąd';

  @override
  String get key => 'Klucz';

  @override
  String get value => 'Wartość';

  @override
  String get ok => 'OK';

  @override
  String get proceed => 'Kontynuuj';

  @override
  String get done => 'Gotowe';

  @override
  String get close => 'Zamknij';

  @override
  String get save => 'Zapisz';

  @override
  String saveLabel(String label) {
    return 'Zapisz $label';
  }

  @override
  String get selectTag => 'Wybierz tag';

  @override
  String get next => 'Dalej';

  @override
  String get previous => 'Wstecz';

  @override
  String get contentShared => 'Udostępniono zawartość';

  @override
  String get setUserImage => 'Ustaw obraz użytkownika';

  @override
  String get setAssistantImage => 'Ustaw obraz asystenta';

  @override
  String get loadUserImage => 'Wczytaj obraz użytkownika';

  @override
  String get loadAssistantImage => 'Wczytaj obraz asystenta';

  @override
  String get userName => 'Nazwa użytkownika';

  @override
  String get assistantName => 'Nazwa asystenta';

  @override
  String get user => 'Użytkownik';

  @override
  String get assistant => 'Asystent';

  @override
  String get cancel => 'Anuluj';

  @override
  String get aiEcosystem => 'Ekosystem AI';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Model Llama CPP';

  @override
  String get remoteModel => 'Model zdalny';

  @override
  String get refreshRemoteModels => 'Odśwież modele zdalne';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Szukaj w sieci lokalnej';

  @override
  String get localNetworkSearchTitle => 'Wyszukiwanie w sieci lokalnej';

  @override
  String get localNetworkSearchContent => 'Ta funkcja wymaga dodatkowych uprawnień do wyszukiwania instancji Ollama w sieci lokalnej.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => 'Parametry modelu';

  @override
  String get addParameter => 'Dodaj parametr';

  @override
  String get removeParameter => 'Usuń parametr';

  @override
  String get saveParameters => 'Zapisz parametry';

  @override
  String get importParameters => 'Importuj parametry';

  @override
  String get exportParameters => 'Eksportuj parametry';

  @override
  String get selectAiEcosystem => 'Wybierz ekosystem AI';

  @override
  String get selectRemoteModel => 'Wybierz model zdalny';

  @override
  String get selectThemeMode => 'Wybierz tryb motywu aplikacji';

  @override
  String get themeMode => 'Tryb motywu';

  @override
  String get themeModeSystem => 'Systemowy';

  @override
  String get themeModeLight => 'Jasny';

  @override
  String get themeModeDark => 'Ciemny';

  @override
  String get themeSeedColor => 'Kolor przewodni motywu';

  @override
  String get editMessage => 'Edytuj wiadomość';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String aiSettings(String aiType) {
    return 'Ustawienia $aiType';
  }

  @override
  String get userSettings => 'Ustawienia użytkownika';

  @override
  String get assistantSettings => 'Ustawienia asystenta';

  @override
  String get systemSettings => 'Ustawienia systemowe';

  @override
  String get systemPrompt => 'Podpowiedź systemowa';

  @override
  String get clearChats => 'Wyczyść czaty';

  @override
  String get resetSettings => 'Zresetuj ustawienia';

  @override
  String get clearCache => 'Wyczyść pamięć podręczną';

  @override
  String get aboutTitle => 'Informacje';

  @override
  String get aboutContent => 'Maid jest darmową, otwartoźródłową, wieloplatformową aplikacją umożliwiającą interakcję z lokalnymi modelami llama.cpp oraz zdalnie z modelami Ollama, Mistral i OpenAI. Maid obsługuje karty postaci SillyTavern, umożliwiając interakcję ze wszystkimi ulubionymi postaciami. Aplikacja pozwala na pobieranie modeli bezpośrednio z Huggingface. Maid jest rozpowszechniany na licencji MIT i dostarczany bez żadnej gwarancji, wyrażonej lub domniemanej. Maid nie jest powiązany z Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft ani żadną inną firmą dostarczającą kompatybilny model.';

  @override
  String get leadMaintainer => 'Główny opiekun projektu';

  @override
  String get apiKey => 'Klucz API';

  @override
  String get baseUrl => 'Bazowy URL';

  @override
  String get clearPrompt => 'Wyczyść podpowiedź';

  @override
  String get submitPrompt => 'Wyślij podpowiedź';

  @override
  String get stopPrompt => 'Zatrzymaj podpowiedź';

  @override
  String get typeMessage => 'Wpisz wiadomość...';

  @override
  String get code => 'Kod';

  @override
  String copyLabel(String label) {
    return 'Kopiuj $label';
  }

  @override
  String labelCopied(String label) {
    return '$label skopiowano do schowka!';
  }

  @override
  String get debugTitle => 'Debugowanie';

  @override
  String get warning => 'Ostrzeżenie';

  @override
  String get nsfwWarning => 'Ten model został celowo zaprojektowany do generowania treści NSFW. Może to obejmować wyraźne treści seksualne lub brutalne, w tym tortury, gwałt, morderstwo i/lub zachowania seksualnie dewiacyjne. Jeśli jesteś wrażliwy na takie tematy lub ich omawianie narusza lokalne prawo, NIE KONTYNUUJ.';

  @override
  String get login => 'Zaloguj się';

  @override
  String get logout => 'Wyloguj się';

  @override
  String get register => 'Zarejestruj się';

  @override
  String get email => 'Email';

  @override
  String get password => 'Hasło';

  @override
  String get confirmPassword => 'Potwierdź hasło';

  @override
  String get resetCode => 'Kod resetujący';

  @override
  String get resetCodeSent => 'Kod resetujący został wysłany na Twój email.';

  @override
  String get sendResetCode => 'Wyślij kod resetujący';

  @override
  String get sendAgain => 'Wyślij ponownie';

  @override
  String get required => 'Wymagane';

  @override
  String get invalidEmail => 'Wprowadź prawidłowy email';

  @override
  String get invalidUserName => 'Musi mieć od 3 do 24 znaków, zawierać litery, cyfry lub podkreślenie';

  @override
  String get invalidPasswordLength => 'Minimum 8 znaków';

  @override
  String get invalidPassword => 'Zawierać wielkie, małe litery, cyfry i symbol';

  @override
  String get passwordNoMatch => 'Hasła nie pasują do siebie';

  @override
  String get createAccount => 'Utwórz konto';

  @override
  String get resetPassword => 'Resetuj hasło';

  @override
  String get backToLogin => 'Powrót do logowania';

  @override
  String get alreadyHaveAccount => 'Mam już konto';

  @override
  String get success => 'Sukces';

  @override
  String get registrationSuccess => 'Rejestracja zakończona sukcesem';

  @override
  String get resetSuccess => 'Twoje hasło zostało pomyślnie zresetowane.';

  @override
  String get emailVerify => 'Sprawdź swój email, aby zweryfikować.';
}
