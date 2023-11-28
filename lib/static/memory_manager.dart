import 'package:maid/static/generation_manager.dart';
import 'package:maid/static/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryManager {
  static void init() {
    SharedPreferences.getInstance().then((prefs) {
      GenerationManager.remote = prefs.getBool("remote") ?? false;
    });
  }

  static void saveMisc() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("remote", GenerationManager.remote);
      Logger.log("Remote Flag Saved: ${GenerationManager.remote}");
    });
    GenerationManager.cleanup();
  }

  static Future<void> saveAll() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.clear();
    saveMisc();
    GenerationManager.cleanup();
  }
}