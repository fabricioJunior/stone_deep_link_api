import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_deep_link_api/stone_deep_link_api_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelStoneDeepLinkApi platform = MethodChannelStoneDeepLinkApi();
  const MethodChannel channel = MethodChannel('stone_deep_link_api');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
