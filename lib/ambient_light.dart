import 'ambient_light_platform_interface.dart';

class AmbientLight {
  Future<double?> currentAmbientLight() async {
    final double? lux = await AmbientLightPlatform.instance.getAmbientLight();
    return lux;
  }

  Stream<double> get ambientLightStream =>
      AmbientLightPlatform.instance.ambientLightStream;
}
