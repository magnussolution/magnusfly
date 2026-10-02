import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magnusfly/api/magnusfly_api_client.dart';
import 'package:magnusfly/flight/tow_geometry.dart';
import 'package:magnusfly/pilot/pilot_screen.dart';
import 'package:magnusfly/pilot/pilot_background_engine.dart';
import 'package:magnusfly/l10n/generated/app_localizations.dart';

class Engine extends PilotBackgroundEngine {
  final samples = StreamController<PilotBarometerSample>.broadcast();
  bool running = false;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<void> start() async {
    running = true;
  }

  @override
  Future<void> stop() async {
    running = false;
  }

  @override
  Stream<PilotBarometerSample> barometerSamples() => samples.stream;
}

class Api extends MagnusFlyApiClient {
  Api(this.engine);
  final Engine engine;
  String status = 'active';
  bool offline = false, confirmed = false;
  int sent = 0;
  final checks = <String>[];
  @override
  Future<AcceptedSession> acceptSession(
          {required String pilotUsername}) async =>
      const AcceptedSession(
          code: 'TEST01',
          pilotUsername: 'pilot',
          pilotToken: 'test-token',
          status: 'active');
  @override
  Future<String> pilotStatus(String pilotToken, {bool stopped = false}) async {
    checks.add('$status/$offline/$stopped');
    if (offline) throw StateError('offline');
    if (stopped) {
      expect(engine.running, false);
      confirmed = true;
    }
    return status;
  }

  @override
  Future<String> sendPilotTelemetry(
      {required String pilotToken,
      required double varioMps,
      required double aglM,
      required double pressureHpa,
      required double relativeAltitudeM,
      required int timestampMillis,
      TowPosition? location}) async {
    sent++;
    return status;
  }
}

void main() {
  testWidgets(
      'accept sends immediately; offline never ends; manual finish stops before ack',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final engine = Engine();
    final api = Api(engine);
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PilotScreen(
            profile: const PilotProfile(
                username: 'pilot',
                name: 'Pilot',
                email: 'p@example.com',
                country: 'BR'),
            apiClient: api,
            pilotBackgroundEngine: engine)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue without GPS'));
    await tester.pumpAndSettle();
    expect(engine.running, true);
    engine.samples.add(PilotBarometerSample(
        pressureHpa: 1013,
        relativeAltitudeMeters: 0,
        timestamp: DateTime.now()));
    await tester.pump();
    await tester.pump();
    expect(api.sent, 1);
    api.offline = true;
    await tester.pump(const Duration(seconds: 5));
    expect(engine.running, true);
    api.offline = false;
    api.status = 'ended';
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(engine.running, false,
        reason:
            '${api.checks} ${tester.widgetList<Text>(find.byType(Text)).map((w) => w.data).join(' | ')}');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(api.confirmed, true,
        reason:
            '${api.checks} ${tester.widgetList<Text>(find.byType(Text)).map((w) => w.data).join(' | ')}');
    expect(find.text('Tow finished'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await engine.samples.close();
  });
}
