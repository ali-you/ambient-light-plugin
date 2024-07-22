import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ambient_light_platform_interface.dart';

/// An implementation of [AmbientLightPlatform] that uses method channels.
class MethodChannelAmbientLight extends AmbientLightPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ambient_light');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
