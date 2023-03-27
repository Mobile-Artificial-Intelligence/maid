import 'llama_platform_interface.dart';

class Llama {
  Future<String?> getPlatformVersion() {
    return LlamaPlatform.instance.getPlatformVersion();
  }
}
