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
  Future<double?> getAmbientLight({bool frontCamera = false}) async {
    final double? lux = await methodChannel
        .invokeMethod('getAmbientLight', {'useFrontCamera': frontCamera});
    return lux;
  }

  @override
  Stream<double> ambientLightStream({bool frontCamera = false}) {
    return eventChannel.receiveBroadcastStream(
        {'useFrontCamera': frontCamera}).map((lux) => lux as double);
  }
}
