import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'stone_deep_link_api_platform_interface.dart';

/// An implementation of [StoneDeepLinkApiPlatform] that uses method channels.
class MethodChannelStoneDeepLinkApi extends StoneDeepLinkApiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('stone_deep_link_api');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
