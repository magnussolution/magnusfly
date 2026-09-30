import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/flight/altitude_engine.dart';

void main() {
  group('PressureAltitudeCalculator', () {
    test('returns approximately zero meters at standard sea-level pressure',
        () {
      const calculator = PressureAltitudeCalculator();

      expect(
        calculator.altitudeMetersFromPressure(standardSeaLevelPressureHpa),
        closeTo(0, 0.01),
      );
    });

    test('returns higher altitude for lower pressure', () {
      const calculator = PressureAltitudeCalculator();

      final altitude = calculator.altitudeMetersFromPressure(900);

      expect(altitude, greaterThan(900));
      expect(altitude, lessThan(1100));
    });

    test('rejects invalid pressure values', () {
      const calculator = PressureAltitudeCalculator();

      expect(
        () => calculator.altitudeMetersFromPressure(0),
        throwsArgumentError,
      );
      expect(
        () => calculator.altitudeMetersFromPressure(double.nan),
        throwsArgumentError,
      );
    });
  });

  group('AglEngine', () {
    test('returns no AGL before ground calibration', () {
      final engine = AglEngine();

      final sample = engine.sampleFromPressure(1000);

      expect(sample.aglMeters, isNull);
      expect(engine.isCalibrated, isFalse);
    });

    test('calibrates ground and reports climb above ground', () {
      final engine = AglEngine();

      final ground = engine.calibrateGroundFromPressure(1000);
      final climb = engine.sampleFromPressure(990);

      expect(ground.aglMeters, 0);
      expect(engine.isCalibrated, isTrue);
      expect(climb.aglMeters, greaterThan(80));
      expect(climb.aglMeters, lessThan(90));
    });

    test('can reset ground calibration', () {
      final engine = AglEngine()..calibrateGroundFromPressure(1000);

      engine.resetCalibration();

      expect(engine.isCalibrated, isFalse);
      expect(engine.sampleFromPressure(990).aglMeters, isNull);
    });
  });
}
