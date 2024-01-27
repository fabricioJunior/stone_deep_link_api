
import 'stone_deep_link_api_platform_interface.dart';

class StoneDeepLinkApi {
  Future<String?> getPlatformVersion() {
    return StoneDeepLinkApiPlatform.instance.getPlatformVersion();
  }
}
