import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ambient_light_method_channel.dart';

abstract class AmbientLightPlatform extends PlatformInterface {
  /// Constructs a AmbientLightPlatform.
  AmbientLightPlatform() : super(token: _token);

  static final Object _token = Object();

  static AmbientLightPlatform _instance = MethodChannelAmbientLight();

  /// The default instance of [AmbientLightPlatform] to use.
  ///
  /// Defaults to [MethodChannelAmbientLight].
  static AmbientLightPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AmbientLightPlatform] when
  /// they register themselves.
  static set instance(AmbientLightPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<double?> getAmbientLight({bool useFrontCameraOnIOS = false}) async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Stream<double> ambientLightStream({bool useFrontCameraOnIOS = false}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
