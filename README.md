# ambient_light

A Flutter plugin to access ambient light sensor data on Android, iOS and macOS. This plugin allows you to retrieve the current ambient light level and listen to continuous updates.

## Features

- **Android:** Uses the `SensorManager` to access the device's ambient light sensor.
- - **iOS:** Uses `CoreMotion` to access the ambient light sensor data on compatible iOS devices.
- **macOS:** Uses `IOKit` to access the ambient light sensor data on compatible macOS devices.
- **Retrieve Current Light Level:** Get the current ambient light level as a single value.
- **Stream Light Level:** Listen to continuous updates of the ambient light level.

## Installation

To use this plugin, add `ambient_light` as a dependency in your `pubspec.yaml` file.

## Usage

Import the package and use the provided methods to get ambient light sensor data.

```dart
import 'package:ambient_light/ambient_light.dart';

void main() async {
  // Get ambient light value
  double? lightLevel = await AmbientLight().currentAmbientLight();
  print('Ambient light level: $lightLevel');

  // Listen to ambient light sensor data stream
  AmbientLight().ambientLightStream.listen((double lightLevel) {
    print('Ambient light level: $lightLevel');
  });
}

```
Note: checkout [Example](https://pub.dev/packages/ambient_light/example) for complete explanation

## Methods

```dart
Future<double?> currentAmbientLight();
```
Returns the current ambient light level as a double. Returns null if the sensor is not available.

```dart
Stream<double> get ambientLightStream;
```
Returns a stream of ambient light sensor data as double.

## iOS

For iOS, the plugin uses CoreMotion to access ambient light sensor data. You need to add the following key to your Info.plist to request access to the camera, which is required for measuring ambient light.

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to the camera to measure ambient light.</string>

```

## Contributions

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes.

## Licence

This project is licensed under the MIT License. See the [LICENSE](https://github.com/ambient-light-plugin/license)  file for details.