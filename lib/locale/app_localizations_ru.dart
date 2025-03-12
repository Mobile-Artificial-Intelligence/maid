// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get friendlyName => 'Русский';

  @override
  String get localeTitle => 'Локаль';

  @override
  String get defaultLocale => 'Локаль по умолчанию';

  @override
  String get loading => 'Загрузка...';

  @override
  String get loadModel => 'Загрузить модель';

  @override
  String get noModelSelected => 'Модель не выбрана';

  @override
  String get noModelLoaded => 'Модель не загружена';

  @override
  String get delete => 'Удалить';

  @override
  String get import => 'Импорт';

  @override
  String get export => 'Экспорт';

  @override
  String get edit => 'Редактировать';

  @override
  String get regenerate => 'Перегенерировать';

  @override
  String get chatsTitle => 'Чаты';

  @override
  String get newChat => 'Новый чат';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String get errorTitle => 'Ошибка';

  @override
  String get key => 'Ключ';

  @override
  String get value => 'Значение';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Готово';

  @override
  String get close => 'Закрыть';

  @override
  String save(String label) {
    return 'Сохранить $label';
  }

  @override
  String get next => 'Далее';

  @override
  String get previous => 'Назад';

  @override
  String get contentShared => 'Контент отправлен';

  @override
  String get setUserImage => 'Установить изображение пользователя';

  @override
  String get setAssistantImage => 'Установить изображение ассистента';

  @override
  String get loadUserImage => 'Загрузить изображение пользователя';

  @override
  String get loadAssistantImage => 'Загрузить изображение ассистента';

  @override
  String get userName => 'Имя пользователя';

  @override
  String get assistantName => 'Имя ассистента';

  @override
  String get user => 'Пользователь';

  @override
  String get assistant => 'Ассистент';

  @override
  String get cancel => 'Отмена';

  @override
  String get aiEcosystem => 'Экосистема ИИ';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Модель Llama CPP';

  @override
  String get remoteModel => 'Удаленная модель';

  @override
  String get refreshRemoteModels => 'Обновить удаленные модели';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Поиск в локальной сети';

  @override
  String get localNetworkSearchTitle => 'Поиск в локальной сети';

  @override
  String get localNetworkSearchContent => 'Эта функция требует дополнительных разрешений для поиска Ollama в вашей локальной сети.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get selectAiEcosystem => 'Выберите экосистему ИИ';

  @override
  String get selectOverrideType => 'Выберите тип переопределения';

  @override
  String get selectRemoteModel => 'Выберите удаленную модель';

  @override
  String get selectThemeMode => 'Выберите тему приложения';

  @override
  String get overrideTypeString => 'Строка';

  @override
  String get overrideTypeInteger => 'Целое число';

  @override
  String get overrideTypeDouble => 'Дробное число';

  @override
  String get overrideTypeBoolean => 'Логическое значение';

  @override
  String get inferanceOverrides => 'Переопределения инференса';

  @override
  String get addOverride => 'Добавить переопределение';

  @override
  String get saveOverride => 'Сохранить переопределение';

  @override
  String get deleteOverride => 'Удалить переопределение';

  @override
  String get themeMode => 'Тема';

  @override
  String get themeModeSystem => 'Системная';

  @override
  String get themeModeLight => 'Светлая';

  @override
  String get themeModeDark => 'Темная';

  @override
  String get themeSeedColor => 'Основной цвет темы';

  @override
  String get editMessage => 'Редактировать сообщение';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String aiSettings(String aiControllerType) {
    return 'Настройки $aiControllerType';
  }

  @override
  String get userSettings => 'Настройки пользователя';

  @override
  String get assistantSettings => 'Настройки ассистента';

  @override
  String get systemSettings => 'Системные настройки';

  @override
  String get systemPrompt => 'Системный промпт';

  @override
  String get clearChats => 'Очистить чаты';

  @override
  String get resetSettings => 'Сбросить настройки';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get aboutTitle => 'О программе';

  @override
  String get aboutContent => 'Maid — это кроссплатформенное бесплатное и открытое приложение для работы с моделями llama.cpp локально, а также с моделями Ollama, Mistral, Google Gemini и OpenAI удаленно. Maid поддерживает карточки персонажей Sillytavern, позволяя взаимодействовать со всеми вашими любимыми персонажами. В приложении можно загружать модели из Hugging Face. Maid распространяется под лицензией MIT и предоставляется без каких-либо гарантий, явных или подразумеваемых. Maid не связан с Hugging Face, Meta (Facebook), MistralAI, OpenAI, Google, Microsoft или другими компаниями, предоставляющими совместимые модели.';

  @override
  String get leadMaintainer => 'Ведущий разработчик';

  @override
  String get apiKey => 'API-ключ';

  @override
  String get baseUrl => 'Базовый URL';

  @override
  String get clearPrompt => 'Очистить промпт';

  @override
  String get submitPrompt => 'Отправить промпт';

  @override
  String get stopPrompt => 'Остановить промпт';

  @override
  String get typeMessage => 'Введите сообщение...';

  @override
  String get code => 'Код';

  @override
  String copyLabel(String label) {
    return 'Копировать $label';
  }

  @override
  String labelCopied(String label) {
    return '$label скопирован в буфер обмена!';
  }
}
