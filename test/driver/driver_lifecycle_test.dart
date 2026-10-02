import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/api/magnusfly_api_client.dart';
import 'package:magnusfly/driver/driver_screen.dart';
import 'package:magnusfly/driver/driver_vario_audio.dart';
import 'package:magnusfly/flight/tow_store.dart';
import 'package:magnusfly/l10n/generated/app_localizations.dart';

class Store extends TowStore {
  Store() : super('test');
  Map<String, dynamic>? saved;
  final records = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>?> session(String role) async => saved;
  @override
  Future<void> saveSession(String role, Map<String, dynamic>? value) async {
    saved = value == null ? null : Map.of(value);
  }

  @override
  Future<void> append(String code, Map<String, dynamic> record) async {
    records.add(record);
  }
}

class Audio extends DriverVarioAudio {
  bool lost = false;
  @override
  void connectionLost(bool value, {bool muted = false}) {
    lost = value;
  }

  @override
  void update(
      {required double? varioMetersPerSecond, required bool telemetryFresh}) {}
}

class Api extends MagnusFlyApiClient {
  bool ended = false, confirmed = false;
  int finishes = 0, age = 0;
  @override
  Future<CreatedSession> createSession({required String pilotUsername}) async =>
      const CreatedSession(
          code: 'ABCDEF',
          pilotUsername: 'pilot',
          driverToken: 'test-token',
          status: 'waiting');
  @override
  Future<DriverTelemetrySnapshot> latestTelemetry(String driverToken) async =>
      DriverTelemetrySnapshot(
          status: ended ? 'ended' : 'active',
          lastSeenAgeMs: age,
          pilotStopped: confirmed,
          telemetry: PilotTelemetry(
              varioMps: 2,
              aglM: 100,
              pressureHpa: 1000,
              relativeAltitudeM: 100,
              timestampMillis: null,
              receivedAgeMs: age,
              id: 1));
  @override
  Future<bool> finishSession(String token) async {
    finishes++;
    ended = true;
    return confirmed;
  }
}

void main() {
  testWidgets(
      'driver keeps session during data loss and waits for manual finish acknowledgement',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = Store(), api = Api(), audio = Audio();
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DriverScreen(apiClient: api, varioAudio: audio, store: store)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'pilot');
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue without GPS'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(api.finishes, 0);
    api.age = 5000;
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(audio.lost, true);
    expect(api.finishes, 0);
    expect(store.saved, isNotNull);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Finish tow'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Finish tow'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Finish', skipOffstage: false));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(store.saved!['finishing'], true);
    expect(store.records.any((r) => r['event'] == 'manual_finish'), true);
    expect(api.finishes, greaterThan(0));
    api.confirmed = true;
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(store.saved, isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
