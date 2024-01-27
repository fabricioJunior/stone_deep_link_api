import 'package:flutter_test/flutter_test.dart';
import 'package:stone_deep_link_api/stone_deep_link_api.dart';
import 'package:stone_deep_link_api/stone_deep_link_api_platform_interface.dart';
import 'package:stone_deep_link_api/stone_deep_link_api_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStoneDeepLinkApiPlatform
    with MockPlatformInterfaceMixin
    implements StoneDeepLinkApiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final StoneDeepLinkApiPlatform initialPlatform = StoneDeepLinkApiPlatform.instance;

  test('$MethodChannelStoneDeepLinkApi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStoneDeepLinkApi>());
  });

  test('getPlatformVersion', () async {
    StoneDeepLinkApi stoneDeepLinkApiPlugin = StoneDeepLinkApi();
    MockStoneDeepLinkApiPlatform fakePlatform = MockStoneDeepLinkApiPlatform();
    StoneDeepLinkApiPlatform.instance = fakePlatform;

    expect(await stoneDeepLinkApiPlugin.getPlatformVersion(), '42');
  });
}
