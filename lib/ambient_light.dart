
import 'ambient_light_platform_interface.dart';

class AmbientLight {
  Future<String?> getPlatformVersion() {
    return AmbientLightPlatform.instance.getPlatformVersion();
  }
}
