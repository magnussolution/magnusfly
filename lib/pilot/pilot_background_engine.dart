import 'dart:async';

import 'package:flutter/services.dart';

class PilotBarometerSample {
  const PilotBarometerSample({
    required this.pressureHpa,
    required this.relativeAltitudeMeters,
    required this.timestamp,
  });

  factory PilotBarometerSample.fromMap(Map<Object?, Object?> map) {
    return PilotBarometerSample(
      pressureHpa: (map['pressureHpa']! as num).toDouble(),
      relativeAltitudeMeters:
          (map['relativeAltitudeMeters']! as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestampMillis']! as int,
        isUtc: true,
      ),
    );
  }

  final double pressureHpa;
  final double relativeAltitudeMeters;
  final DateTime timestamp;
}

class PilotBackgroundEngine {
  PilotBackgroundEngine({
    MethodChannel methodChannel = const MethodChannel(_methodChannelName),
    EventChannel eventChannel = const EventChannel(_eventChannelName),
  })  : _methodChannel = methodChannel,
        _eventChannel = eventChannel;

  static const _methodChannelName =
      'com.magnussolution.magnusfly/pilot_background';
  static const _eventChannelName =
      'com.magnussolution.magnusfly/pilot_barometer';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Future<bool> isAvailable() async {
    return await _methodChannel.invokeMethod<bool>('isAvailable') ?? false;
  }

  Future<bool> isRunning() async {
    return await _methodChannel.invokeMethod<bool>('isRunning') ?? false;
  }

  Future<void> start() async {
    await _methodChannel.invokeMethod<void>('start');
  }

  Future<void> stop() async {
    await _methodChannel.invokeMethod<void>('stop');
  }

  Stream<PilotBarometerSample> barometerSamples() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return PilotBarometerSample.fromMap(event as Map<Object?, Object?>);
    });
  }
}
