import 'ambient_light_platform_interface.dart';

class AmbientLight {
  Future<double?> currentAmbientLight({bool useFrontCamera = false}) async {
    final double? lux = await AmbientLightPlatform.instance
        .getAmbientLight(useFrontCameraOnIOS: useFrontCamera);
    return lux;
  }

  Stream<double> ambientLightStream({bool useFrontCamera = false}) =>
      AmbientLightPlatform.instance
          .ambientLightStream(useFrontCameraOnIOS: useFrontCamera);
}
