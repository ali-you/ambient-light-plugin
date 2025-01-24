import 'ambient_light_platform_interface.dart';

class AmbientLight {
  AmbientLight({this.frontCamera = false});

  /// if [frontCamera] is true, the front camera will be used.
  /// Important: [frontCamera] is only available on iOS.
  final bool frontCamera;

  /// Returns the current ambient light in lux.
  Future<double?> currentAmbientLight() async {
    final double? lux = await AmbientLightPlatform.instance
        .getAmbientLight(frontCamera: frontCamera);
    return lux;
  }

  /// Returns a stream of ambient light in lux.
  Stream<double> get ambientLightStream => AmbientLightPlatform.instance
      .ambientLightStream(frontCamera: frontCamera);
}
