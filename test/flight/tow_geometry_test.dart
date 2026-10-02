import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/flight/tow_geometry.dart';

void main() {
  final now = DateTime.utc(2026);
  final driver = TowPosition(0, 0, 2, now);
  final pilot = TowPosition(0, 200 / 6371000 * 180 / math.pi, 2, now);
  test('flat terrain triangle and exact color boundaries', () {
    final result = TowGeometry.calculate(
        pilot: pilot, driver: driver, aglMeters: 100, now: now)!;
    expect(result.horizontalMeters, closeTo(200, 0.01));
    expect(result.ropeMeters, closeTo(223.6068, 0.01));
    expect(result.angleDegrees, closeTo(26.565, 0.01));
    expect(const TowGeometry(1, 1, 29.99).band, AngleBand.low);
    expect(const TowGeometry(1, 1, 30).band, AngleBand.reference);
    expect(const TowGeometry(1, 1, 50).band, AngleBand.reference);
    expect(const TowGeometry(1, 1, 50.01).band, AngleBand.high);
  });
  test('stale, uncertain, future and near-zero fixes do not produce an angle',
      () {
    for (final p in [
      TowPosition(0, .001, 21, now),
      TowPosition(0, .001, 2, now.subtract(const Duration(seconds: 4))),
      TowPosition(0, .001, 2, now.add(const Duration(seconds: 1))),
      driver
    ]) {
      expect(
          TowGeometry.calculate(
              pilot: p, driver: driver, aglMeters: 0, now: now),
          isNull);
    }
  });
  test('stationary driver does not invalidate geometry or end anything', () {
    expect(
        TowGeometry.calculate(
            pilot: pilot, driver: driver, aglMeters: 200, now: now),
        isNotNull);
  });
}
