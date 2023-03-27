import 'package:flutter_test/flutter_test.dart';
import 'package:llama/llama.dart';
import 'package:llama/llama_platform_interface.dart';
import 'package:llama/llama_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLlamaPlatform
    with MockPlatformInterfaceMixin
    implements LlamaPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LlamaPlatform initialPlatform = LlamaPlatform.instance;

  test('$MethodChannelLlama is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLlama>());
  });

  test('getPlatformVersion', () async {
    Llama llamaPlugin = Llama();
    MockLlamaPlatform fakePlatform = MockLlamaPlatform();
    LlamaPlatform.instance = fakePlatform;

    expect(await llamaPlugin.getPlatformVersion(), '42');
  });
}
