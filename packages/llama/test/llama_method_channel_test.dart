import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llama/llama_method_channel.dart';

void main() {
  MethodChannelLlama platform = MethodChannelLlama();
  const MethodChannel channel = MethodChannel('llama');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
