import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ambient_light_platform_interface.dart';

/// An implementation of [AmbientLightPlatform] that uses method channels.
class MethodChannelAmbientLight extends AmbientLightPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('ambient_light.aliyou.dev');
  @visibleForTesting
  final EventChannel eventChannel =
      const EventChannel('ambient_light_stream.aliyou.dev');

  @override
  Future<double?> getAmbientLight() async {
    final double? lux = await methodChannel.invokeMethod('getAmbientLight');
    return lux;
  }

  @override
  Stream<double> get ambientLightStream {
    return eventChannel.receiveBroadcastStream().map((lux) => lux as double);
  }
}
