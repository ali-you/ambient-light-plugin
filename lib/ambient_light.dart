import 'ambient_light_platform_interface.dart';

class AmbientLight {
  /// Returns the current ambient light in lux.
  /// if [frontCamera] is true, the front camera will be used.
  /// Important: [frontCamera] is only available on iOS.
  Future<double?> currentAmbientLight({bool frontCamera = false}) async {
    final double? lux = await AmbientLightPlatform.instance
        .getAmbientLight(frontCamera: frontCamera);
    return lux;
  }

  /// Returns a stream of ambient light in lux.
  /// if [frontCamera] is true, the front camera will be used.
  /// Important: [frontCamera] is only available on iOS.
  Stream<double> ambientLightStream({bool frontCamera = false}) =>
      AmbientLightPlatform.instance
          .ambientLightStream(frontCamera: frontCamera);
}
