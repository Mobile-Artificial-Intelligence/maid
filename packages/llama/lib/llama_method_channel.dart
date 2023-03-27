import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'llama_platform_interface.dart';

/// An implementation of [LlamaPlatform] that uses method channels.
class MethodChannelLlama extends LlamaPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('llama');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
