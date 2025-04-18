part of 'package:maid/main.dart';

class AppSettings extends ChangeNotifier {
  static AppSettings? _instance;
  static AppSettings get instance {
    _instance ??= AppSettings.load();
    return _instance!;
  }

  AppSettings({
    Uint8List? userImage,
    String? userName,
    Uint8List? assistantImage,
    String? assistantName,
    Color seedColor = Colors.blue,
    ThemeMode themeMode = ThemeMode.system,
    String? systemPrompt,
  }) : _userImage = userImage,
       _userName = userName,
       _assistantImage = assistantImage,
       _assistantName = assistantName,
       _seedColor = seedColor,
       _themeMode = themeMode,
       _systemPrompt = systemPrompt;
  
  AppSettings.load() {
    load();
  }

  Uint8List? _userImage;

  Uint8List? get userImage => _userImage;

  set userImage(Uint8List? newUserImage) {
    _userImage = newUserImage;

    save();
    notifyListeners();
  }

   void loadUserImage() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick User Image",
      type: FileType.image,
      allowMultiple: false,
      allowCompression: false
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.bytes == null) {
      _userImage = null;
    }
    else {
      _userImage = result.files.single.bytes;
    }

    save();
    notifyListeners();
  }

  String? _userName;

  String? get userName => _userName;

  set userName(String? newUserName) {
    if (newUserName == null || newUserName.isEmpty) {
      _userName = null;
    }
    else {
      _userName = newUserName;
    }

    save();
    notifyListeners();
  }

  void setUserName(String newUserName) {
    userName = newUserName;
  }

  Uint8List? _assistantImage;

  Uint8List? get assistantImage => _assistantImage;

  set assistantImage(Uint8List? newAssistantImage) {
    _assistantImage = newAssistantImage;

    save();
    notifyListeners();
    if (_assistantImage == null) return;

    final image = img.decodeImage(_assistantImage!);
  
    sillyTavernDecoder(image?.textData);
  }

  void sillyTavernDecoder(Map<String, String>? imageData) {
    if (imageData == null) return;

    Uint8List utf8Character = base64.decode(imageData["Chara"] ?? imageData["chara"] ?? '');

    String stringCharacter = utf8.decode(utf8Character);

    Map<String, dynamic> character = jsonDecode(stringCharacter);

    if (character.isEmpty) return;

    String result = '';

    if (character['data'] != null) {
      character = character['data'];
    }

    final name = character['name'] as String?;
    if (name != null && name.trim().isNotEmpty) {
      result += '### Character Name: ${name.titleize}\n\n';
      assistantName = name;
    }

    final description = character['description'] as String?;
    if (description != null && description.trim().isNotEmpty) {
      result += '### Description\n\n${description.titleize}\n\n';
    }

    final personality = character['personality'] as String?;
    if (personality != null && personality.trim().isNotEmpty) {
      result += '### Personality\n\n${personality.titleize}\n\n';
    }

    final scenario = character['scenario'] as String?;
    if (scenario != null && scenario.trim().isNotEmpty) {
      result += '### Scenario\n\n${scenario.titleize}\n\n';
    }

    final example = character['mes_example'] as String?;
    if (example != null && example.trim().isNotEmpty) {
      result += '### Message Example\n\n${example.titleize}\n\n';
    }

    systemPrompt = result;
  }

  void loadAssistantImage() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick Assistant Image",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false
    );

    if (
      result == null ||
      result.files.isEmpty ||
      result.files.single.bytes == null
    ) {
      _assistantImage = null;
      save();
      notifyListeners();
      return;
    }
    
    _assistantImage = result.files.single.bytes;
    notifyListeners();

    final image = img.decodeImage(_assistantImage!);

    sillyTavernDecoder(image?.textData);
  }

  String? _assistantName;

  String? get assistantName => _assistantName;

  set assistantName(String? newAssistantName) {
    if (newAssistantName == null || newAssistantName.isEmpty) {
      _assistantName = null;
    }
    else {
      _assistantName = newAssistantName;
    }

    save();
    notifyListeners();
  }

  void setAssistantName(String newAssistantName) {
    assistantName = newAssistantName;
  }

  Color _seedColor = Colors.blue;

  Color get seedColor => _seedColor;

  set seedColor(Color newSeedColor) {
    _seedColor = newSeedColor;
    save();
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode newThemeMode) {
    _themeMode = newThemeMode;
    save();
    notifyListeners();
  }

  Locale? _locale;

  Locale? get locale => _locale;

  set locale(Locale? newLocale) {
    _locale = newLocale;
    save();
    notifyListeners();
  }

  String? _systemPrompt;

  String? get systemPrompt => _systemPrompt;

  set systemPrompt(String? newSystemPrompt) {
    if (newSystemPrompt == null || newSystemPrompt.isEmpty) {
      _systemPrompt = null;
    }
    else {
      _systemPrompt = newSystemPrompt;
    }

    save();
    notifyListeners();
  }

  void setSystemPrompt(String newSystemPrompt) {
    systemPrompt = newSystemPrompt;
  }

  void load() async {
    final prefs = await SharedPreferences.getInstance();
    
    final userImageBytes = prefs.getString('userImage');
    if (userImageBytes != null) {
      userImage = base64.decode(userImageBytes);
    }

    userName = prefs.getString('userName');
    if (userName == null && Supabase.instance.client.auth.currentUser != null) {
      userName = Supabase.instance.client.auth.currentUser?.userMetadata?['username'] as String?;
    }
    
    final assistantImagePath = prefs.getString('assistantImage');
    if (assistantImagePath != null) {
      assistantImage = base64.decode(assistantImagePath);
    }

    assistantName = prefs.getString('assistantName');

    final seedColorR = prefs.getInt('seedColorR');
    final seedColorG = prefs.getInt('seedColorG');
    final seedColorB = prefs.getInt('seedColorB');
    final seedColorA = prefs.getInt('seedColorA');
    if (seedColorR != null && seedColorG != null && seedColorB != null && seedColorA != null) {
      seedColor = Color.fromARGB(
        seedColorA.toInt(),
        seedColorR.toInt(),
        seedColorG.toInt(),
        seedColorB.toInt()
      );
    }

    final themeModeIndex = prefs.getInt('themeMode');
    if (themeModeIndex != null) {
      themeMode = ThemeMode.values[themeModeIndex];
    }

    systemPrompt = prefs.getString('systemPrompt');

    final localeLanguageCode = prefs.getString('localeLanguageCode');
    if (localeLanguageCode != null) {
      locale = Locale(localeLanguageCode);
    }

    notifyListeners();
  }

  void save() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (userImage != null) {
      prefs.setString('userImage', base64.encode(userImage!));
    }
    else {
      prefs.remove('userImage');
    }

    if (userName != null && userName!.isNotEmpty) {
      prefs.setString('userName', userName!);

      if (Supabase.instance.client.auth.currentUser != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'username': userName,
            }
          )
        );
      }
    }
    else {
      prefs.remove('userName');
    }

    if (assistantImage != null) {
      prefs.setString('assistantImage', base64.encode(assistantImage!));
    }
    else {
      prefs.remove('assistantImage');
    }

    if (assistantName != null && assistantName!.isNotEmpty) {
      prefs.setString('assistantName', assistantName!);
    }
    else {
      prefs.remove('assistantName');
    }

    if (systemPrompt != null && systemPrompt!.isNotEmpty) {
      prefs.setString('systemPrompt', systemPrompt!);
    }
    else {
      prefs.remove('systemPrompt');
    }

    if (locale != null) {
      prefs.setString('localeLanguageCode', locale!.languageCode);
    }
    else {
      prefs.remove('localeLanguageCode');
    }

    prefs.setInt('seedColorR', (seedColor.r *  255).toInt());
    prefs.setInt('seedColorG', (seedColor.g *  255).toInt());
    prefs.setInt('seedColorB', (seedColor.b *  255).toInt());
    prefs.setInt('seedColorA', (seedColor.a *  255).toInt());

    prefs.setInt('themeMode', themeMode.index);
  }

  void clear() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.remove('userImage');
    userImage = null;

    prefs.remove('userName');
    userName = null;

    prefs.remove('assistantImage');
    assistantImage = null;

    prefs.remove('assistantName');
    assistantName = null;

    prefs.remove('systemPrompt');
    systemPrompt = null;

    prefs.remove('localeLanguageCode');
    locale = null;

    prefs.remove('seedColorR');
    prefs.remove('seedColorG');
    prefs.remove('seedColorB');
    prefs.remove('seedColorA');
    seedColor = Colors.blue;

    prefs.remove('themeMode');
    themeMode = ThemeMode.system;

    notifyListeners();
  }
}