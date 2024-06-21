class Logger {
  static String _logString = "";

  static String get getLog => _logString;

  static void log(String message) {
    _logString += "$message\n";
  }

  static void clear() {
    _logString = "";
  }
}