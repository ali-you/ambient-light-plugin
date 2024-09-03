import 'package:flutter_test/flutter_test.dart';
import 'package:ambient_light/ambient_light.dart';
import 'package:ambient_light/ambient_light_platform_interface.dart';
import 'package:ambient_light/ambient_light_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAmbientLightPlatform
    with MockPlatformInterfaceMixin
    implements AmbientLightPlatform {
  @override
  Stream<double> ambientLightStream({bool useFrontCameraOnIOS = false}) =>
      Stream.value(42);

  @override
  Future<double?> getAmbientLight({bool useFrontCameraOnIOS = false}) =>
      Future.value(42);
}

void main() {
  final AmbientLightPlatform initialPlatform = AmbientLightPlatform.instance;

  test('$MethodChannelAmbientLight is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAmbientLight>());
  });

  test('getPlatformVersion', () async {
    AmbientLight ambientLightPlugin = AmbientLight();
    MockAmbientLightPlatform fakePlatform = MockAmbientLightPlatform();
    AmbientLightPlatform.instance = fakePlatform;

    expect(await ambientLightPlugin.currentAmbientLight(), '42');
  });
}
