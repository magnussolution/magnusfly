import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/api/magnusfly_api_client.dart';
import 'package:magnusfly/driver/driver_screen.dart';
import 'package:magnusfly/flight/tow_location.dart';
import 'package:magnusfly/flight/tow_geometry.dart';
import 'package:magnusfly/l10n/generated/app_localizations.dart';
import 'driver_lifecycle_test.dart' show Store, Audio;

class Gps extends TowLocation {
  @override
  Future<bool> prepare() async => true;
  @override
  void start({required bool pilot, required String notification}) {
    latest = TowPosition(0, 0, 2, DateTime.now());
  }
}

class LayoutApi extends MagnusFlyApiClient {
  @override
  Future<DriverTelemetrySnapshot> latestTelemetry(String driverToken) async =>
      DriverTelemetrySnapshot(
          status: 'active',
          lastSeenAgeMs: 0,
          telemetry: PilotTelemetry(
              varioMps: 2.5,
              aglM: 150,
              pressureHpa: 1000,
              relativeAltitudeM: 150,
              timestampMillis: DateTime.now().millisecondsSinceEpoch,
              receivedAgeMs: 0,
              id: 1,
              location: const {
                'latitude': 0,
                'longitude': .0018,
                'accuracy': 2,
                'ageMs': 0
              }));
}

void main() {
  for (final size in [
    const Size(360, 800),
    const Size(320, 568),
    const Size(844, 390)
  ]) {
    testWidgets('driver layout ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = Store()
        ..saved = {
          'token': 'test-token',
          'code': 'ABCDEF',
          'pilot': 'pilot',
          'finishing': false
        };
      final key = GlobalKey();
      if (Platform.environment['TOW_SCREENSHOTS'] == '1') {
        await tester.runAsync(() async {
          final loader = FontLoader('TowTestFont');
          loader.addFont(File('/System/Library/Fonts/Supplemental/Arial.ttf')
              .readAsBytes()
              .then(ByteData.sublistView));
          await loader.load();
        });
      }
      await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: MaterialApp(
              theme: ThemeData(
                  fontFamily: 'TowTestFont',
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
              locale: const Locale('pt'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaler:
                          TextScaler.linear(size.width == 320 ? 1.5 : 1)),
                  child: child!),
              home: DriverScreen(
                  store: store,
                  apiClient: LayoutApi(),
                  varioAudio: Audio(),
                  location: Gps()))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      expect(find.text('37'), findsOneWidget);
      if (Platform.environment['TOW_SCREENSHOTS'] == '1') {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/tow-screenshots').create(recursive: true);
          await File('build/tow-screenshots/driver-${size.width.toInt()}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
