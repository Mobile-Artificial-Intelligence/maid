part of 'package:maid/main.dart';

class AppSettings extends ChangeNotifier {
  AppSettings() {
    load();
  }

  static AppSettings of(BuildContext context, {bool listen = false}) => 
    Provider.of<AppSettings>(context, listen: listen);

  File? _userImage;

  File? get userImage => _userImage;

  set userImage(File? newUserImage) {
    if (newUserImage == null || newUserImage.path.isEmpty) {
      _userImage = null;
    }
    else {
      _userImage = newUserImage;
    }

    save();
    notifyListeners();
  }

   void loadUserImage() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.image,
      allowMultiple: false,
      allowCompression: false
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      _userImage = null;
    }
    else {
      _userImage = File(result.files.single.path!);
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

  File? _assistantImage;

  File? get assistantImage => _assistantImage;

  set assistantImage(File? newAssistantImage) {
    if (newAssistantImage == null || newAssistantImage.path.isEmpty) {
      _assistantImage = null;
    }
    else {
      _assistantImage = newAssistantImage;
    }

    save();
    notifyListeners();
  }

  void loadAssistantImage() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false
    );

    if (
      result == null ||
      result.files.isEmpty ||
      result.files.single.path == null
    ) {
      _assistantImage = null;
      save();
      notifyListeners();
      return;
    }
    
    _assistantImage = File(result.files.single.path!);
    notifyListeners();

    final bytes = _assistantImage!.readAsBytesSync();

    final image = img.decodeImage(bytes);

    _systemPrompt = sillyTavernDecoder(image?.textData);

    save();
    notifyListeners();
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
    
    final userImagePath = prefs.getString('userImage');
    if (userImagePath != null && userImagePath.isNotEmpty) {
      userImage = File(userImagePath);
    }

    userName = prefs.getString('userName');
    
    final assistantImagePath = prefs.getString('assistantImage');
    if (assistantImagePath != null && assistantImagePath.isNotEmpty) {
      assistantImage = File(assistantImagePath);
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

    notifyListeners();
  }

  void save() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (userImage != null && userImage!.path.isNotEmpty) {
      prefs.setString('userImage', userImage!.path);
    }

    if (userName != null && userName!.isNotEmpty) {
      prefs.setString('userName', userName!);
    }

    if (assistantImage != null && assistantImage!.path.isNotEmpty) {
      prefs.setString('assistantImage', assistantImage!.path);
    }

    if (assistantName != null && assistantName!.isNotEmpty) {
      prefs.setString('assistantName', assistantName!);
    }

    if (systemPrompt != null && systemPrompt!.isNotEmpty) {
      prefs.setString('systemPrompt', systemPrompt!);
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