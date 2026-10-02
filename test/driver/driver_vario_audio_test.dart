import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/driver/driver_vario_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test_driver_vario_audio');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('plays a beep for fresh climb telemetry', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });

    final audio = DriverVarioAudio(methodChannel: channel);
    addTearDown(audio.dispose);

    audio.update(varioMetersPerSecond: 2.0, telemetryFresh: true);
    await Future<void>.delayed(Duration.zero);

    expect(calls, hasLength(1));
    expect(calls.single.method, 'playBeep');
    expect(calls.single.arguments, containsPair('durationMs', 90));
  });

  test('does not play when disabled or telemetry is stale', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });

    final audio = DriverVarioAudio(methodChannel: channel);
    addTearDown(audio.dispose);

    audio.update(varioMetersPerSecond: 2.0, telemetryFresh: false);
    audio.enabled = false;
    audio.update(varioMetersPerSecond: 2.0, telemetryFresh: true);
    await Future<void>.delayed(Duration.zero);

    expect(calls, isEmpty);
  });

  testWidgets(
      'connection alarm is distinct, independently mutable and cancels on disposal',
      (tester) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    final audio = DriverVarioAudio(methodChannel: channel);
    audio.enabled = false;
    audio.connectionLost(true);
    await tester.pump();
    expect(calls.single.arguments, containsPair('durationMs', 450));
    audio.connectionLost(true, muted: true);
    calls.clear();
    await tester.pump(const Duration(seconds: 4));
    expect(calls, isEmpty);
    audio.connectionLost(false);
    await tester.pump();
    expect(calls.single.arguments, containsPair('durationMs', 120));
    audio.connectionLost(true);
    audio.dispose();
    calls.clear();
    await tester.pump(const Duration(seconds: 4));
    expect(calls, isEmpty);
  });
}
