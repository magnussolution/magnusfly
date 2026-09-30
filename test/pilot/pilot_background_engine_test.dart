import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/pilot/pilot_background_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel(
    'com.magnussolution.magnusfly/pilot_background_test',
  );
  const eventChannel = EventChannel(
    'com.magnussolution.magnusfly/pilot_barometer_test',
  );

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('forwards start and stop calls to the native pilot engine', () async {
    final calls = <String>[];
    final engine = PilotBackgroundEngine(
      methodChannel: methodChannel,
      eventChannel: eventChannel,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
      calls.add(call.method);
      return null;
    });

    await engine.start();
    await engine.stop();

    expect(calls, ['start', 'stop']);
  });

  test('reads native availability and running state', () async {
    final engine = PilotBackgroundEngine(
      methodChannel: methodChannel,
      eventChannel: eventChannel,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
      return switch (call.method) {
        'isAvailable' => true,
        'isRunning' => false,
        _ => null,
      };
    });

    expect(await engine.isAvailable(), isTrue);
    expect(await engine.isRunning(), isFalse);
  });

  test('parses barometer samples from native maps', () {
    final sample = PilotBarometerSample.fromMap({
      'pressureHpa': 1001.5,
      'relativeAltitudeMeters': 12.25,
      'timestampMillis': 1790774400000,
    });

    expect(sample.pressureHpa, 1001.5);
    expect(sample.relativeAltitudeMeters, 12.25);
    expect(
      sample.timestamp,
      DateTime.fromMillisecondsSinceEpoch(
        1790774400000,
        isUtc: true,
      ),
    );
  });
}
