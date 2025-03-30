// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get friendlyName => 'Español';

  @override
  String get localeTitle => 'Idioma';

  @override
  String get defaultLocale => 'Idioma predeterminado';

  @override
  String get loading => 'Cargando...';

  @override
  String get loadModel => 'Cargar modelo';

  @override
  String get downloadModel => 'Descargar modelo';

  @override
  String get noModelSelected => 'Ningún modelo seleccionado';

  @override
  String get noModelLoaded => 'Ningún modelo cargado';

  @override
  String get localModels => 'Modelos locales';

  @override
  String get size => 'Tamaño';

  @override
  String get parameters => 'Parámetros';

  @override
  String get delete => 'Eliminar';

  @override
  String get select => 'Seleccionar';

  @override
  String get import => 'Importar';

  @override
  String get export => 'Exportar';

  @override
  String get edit => 'Editar';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get anErrorOccurred => 'Ocurrió un error';

  @override
  String get errorTitle => 'Error';

  @override
  String get key => 'Clave';

  @override
  String get value => 'Valor';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Hecho';

  @override
  String get close => 'Cerrar';

  @override
  String get save => 'Guardar';

  @override
  String saveLabel(String label) {
    return 'Guardar $label';
  }

  @override
  String get selectTag => 'Seleccionar etiqueta';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get contentShared => 'Contenido compartido';

  @override
  String get setUserImage => 'Establecer imagen de usuario';

  @override
  String get setAssistantImage => 'Establecer imagen de asistente';

  @override
  String get loadUserImage => 'Cargar imagen de usuario';

  @override
  String get loadAssistantImage => 'Cargar imagen de asistente';

  @override
  String get userName => 'Nombre de usuario';

  @override
  String get assistantName => 'Nombre del asistente';

  @override
  String get user => 'Usuario';

  @override
  String get assistant => 'Asistente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get aiEcosystem => 'Ecosistema IA';

  @override
  String get llamaCpp => 'Llama CPP';

  @override
  String get llamaCppModel => 'Modelo Llama CPP';

  @override
  String get remoteModel => 'Modelo remoto';

  @override
  String get refreshRemoteModels => 'Actualizar modelos remotos';

  @override
  String get ollama => 'Ollama';

  @override
  String get searchLocalNetwork => 'Buscar en la red local';

  @override
  String get localNetworkSearchTitle => 'Búsqueda en la red local';

  @override
  String get localNetworkSearchContent => 'Esta función requiere permisos adicionales para buscar instancias de Ollama en su red local.';

  @override
  String get openAI => 'OpenAI';

  @override
  String get mistral => 'Mistral';

  @override
  String get anthropic => 'Anthropic';

  @override
  String get gemini => 'Gemini';

  @override
  String get modelParameters => 'Parámetros del modelo';

  @override
  String get addParameter => 'Añadir parámetro';

  @override
  String get removeParameter => 'Eliminar parámetro';

  @override
  String get saveParameters => 'Guardar parámetros';

  @override
  String get importParameters => 'Importar parámetros';

  @override
  String get exportParameters => 'Exportar parámetros';

  @override
  String get selectAiEcosystem => 'Seleccionar ecosistema de IA';

  @override
  String get selectRemoteModel => 'Seleccionar modelo remoto';

  @override
  String get selectThemeMode => 'Seleccionar modo de tema';

  @override
  String get themeMode => 'Modo de tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeSeedColor => 'Color base del tema';

  @override
  String get editMessage => 'Editar mensaje';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String aiSettings(String aiControllerType) {
    return 'Configuración de $aiControllerType';
  }

  @override
  String get userSettings => 'Configuración de usuario';

  @override
  String get assistantSettings => 'Configuración del asistente';

  @override
  String get systemSettings => 'Configuración del sistema';

  @override
  String get systemPrompt => 'Prompt del sistema';

  @override
  String get clearChats => 'Borrar chats';

  @override
  String get resetSettings => 'Restablecer configuración';

  @override
  String get clearCache => 'Limpiar caché';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutContent => 'Maid es una aplicación gratuita y de código abierto multiplataforma para interactuar con modelos Llama.cpp localmente y de forma remota con Ollama, Mistral, Google Gemini y OpenAI. Maid admite tarjetas de personajes de Sillytavern para que puedas interactuar con tus personajes favoritos. También permite descargar una lista seleccionada de modelos directamente desde Huggingface. Maid se distribuye bajo la licencia MIT y se proporciona sin garantía de ningún tipo, expresa o implícita. Maid no está afiliada con Huggingface, Meta (Facebook), MistralAI, OpenAI, Google, Microsoft ni ninguna otra empresa que proporcione modelos compatibles con esta aplicación.';

  @override
  String get leadMaintainer => 'Mantenedor principal';

  @override
  String get apiKey => 'Clave API';

  @override
  String get baseUrl => 'URL base';

  @override
  String get clearPrompt => 'Borrar prompt';

  @override
  String get submitPrompt => 'Enviar prompt';

  @override
  String get stopPrompt => 'Detener prompt';

  @override
  String get typeMessage => 'Escribe un mensaje...';

  @override
  String get code => 'Código';

  @override
  String copyLabel(String label) {
    return 'Copiar $label';
  }

  @override
  String labelCopied(String label) {
    return '¡$label copiado al portapapeles!';
  }
}
