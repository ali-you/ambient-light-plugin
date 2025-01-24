import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ambient_light/ambient_light.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AmbientLight _ambientLight = AmbientLight(frontCamera: true);
  double? _currentAmbientLight;
  double? _currentAmbientLightStream;
  StreamSubscription<double>? _ambientLightSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _ambientLightSubscription?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _startListening() async {
    _ambientLightSubscription?.cancel();
    _ambientLightSubscription = _ambientLight.ambientLightStream.listen((lux) {
      if (!mounted) return;
      setState(() {
        _currentAmbientLightStream = lux;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ambient Light Sensor'),
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _currentAmbientLight != null
                          ? 'Ambient Light: ${_currentAmbientLight!.toStringAsFixed(2)} lux'
                          : 'Not determine !',
                      style: const TextStyle(fontSize: 24),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          _currentAmbientLight =
                              await _ambientLight.currentAmbientLight();
                          setState(() {});
                        },
                        child: const Text("get current ambient light")),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _currentAmbientLightStream != null
                      ? 'Ambient Light Stream:\n${_currentAmbientLightStream!.toStringAsFixed(2)} lux'
                      : 'Fetching ambient light...',
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
