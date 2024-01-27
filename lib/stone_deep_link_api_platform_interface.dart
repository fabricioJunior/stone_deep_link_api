import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'stone_deep_link_api_method_channel.dart';

abstract class StoneDeepLinkApiPlatform extends PlatformInterface {
  /// Constructs a StoneDeepLinkApiPlatform.
  StoneDeepLinkApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static StoneDeepLinkApiPlatform _instance = MethodChannelStoneDeepLinkApi();

  /// The default instance of [StoneDeepLinkApiPlatform] to use.
  ///
  /// Defaults to [MethodChannelStoneDeepLinkApi].
  static StoneDeepLinkApiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StoneDeepLinkApiPlatform] when
  /// they register themselves.
  static set instance(StoneDeepLinkApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
