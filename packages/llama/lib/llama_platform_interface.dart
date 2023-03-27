import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'llama_method_channel.dart';

abstract class LlamaPlatform extends PlatformInterface {
  /// Constructs a LlamaPlatform.
  LlamaPlatform() : super(token: _token);

  static final Object _token = Object();

  static LlamaPlatform _instance = MethodChannelLlama();

  /// The default instance of [LlamaPlatform] to use.
  ///
  /// Defaults to [MethodChannelLlama].
  static LlamaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LlamaPlatform] when
  /// they register themselves.
  static set instance(LlamaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
