import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/flight/variometer_engine.dart';

void main() {
  group('VariometerEngine', () {
    test('returns no vario for the first sample', () {
      final engine = VariometerEngine();

      final sample = engine.sample(
        altitudeMeters: 100,
        timestamp: DateTime.utc(2026),
      );

      expect(sample.verticalSpeedMetersPerSecond, isNull);
    });

    test('calculates positive climb rate in meters per second', () {
      final engine = VariometerEngine();
      final start = DateTime.utc(2026);

      engine.sample(altitudeMeters: 100, timestamp: start);
      final sample = engine.sample(
        altitudeMeters: 110,
        timestamp: start.add(const Duration(seconds: 5)),
      );

      expect(sample.verticalSpeedMetersPerSecond, 2);
    });

    test('calculates negative sink rate in meters per second', () {
      final engine = VariometerEngine();
      final start = DateTime.utc(2026);

      engine.sample(altitudeMeters: 120, timestamp: start);
      final sample = engine.sample(
        altitudeMeters: 114,
        timestamp: start.add(const Duration(seconds: 3)),
      );

      expect(sample.verticalSpeedMetersPerSecond, -2);
    });

    test('smooths consecutive vario samples', () {
      final engine = VariometerEngine(smoothingFactor: 0.5);
      final start = DateTime.utc(2026);

      engine.sample(altitudeMeters: 100, timestamp: start);
      engine.sample(
        altitudeMeters: 110,
        timestamp: start.add(const Duration(seconds: 5)),
      );
      final sample = engine.sample(
        altitudeMeters: 125,
        timestamp: start.add(const Duration(seconds: 10)),
      );

      expect(sample.verticalSpeedMetersPerSecond, 2.5);
    });

    test('rejects non-increasing timestamps', () {
      final engine = VariometerEngine();
      final start = DateTime.utc(2026);

      engine.sample(altitudeMeters: 100, timestamp: start);

      expect(
        () => engine.sample(altitudeMeters: 101, timestamp: start),
        throwsArgumentError,
      );
    });

    test('can reset sample history', () {
      final engine = VariometerEngine();
      final start = DateTime.utc(2026);

      engine.sample(altitudeMeters: 100, timestamp: start);
      engine.reset();
      final sample = engine.sample(
        altitudeMeters: 110,
        timestamp: start.add(const Duration(seconds: 1)),
      );

      expect(sample.verticalSpeedMetersPerSecond, isNull);
    });
  });
}
