import 'dart:math' as math;

const double standardSeaLevelPressureHpa = 1013.25;

class PressureAltitudeCalculator {
  const PressureAltitudeCalculator({
    this.seaLevelPressureHpa = standardSeaLevelPressureHpa,
  });

  final double seaLevelPressureHpa;

  double altitudeMetersFromPressure(double pressureHpa) {
    _checkPositiveFinite(pressureHpa, 'pressureHpa');
    _checkPositiveFinite(seaLevelPressureHpa, 'seaLevelPressureHpa');

    return (44330 *
            (1 - math.pow(pressureHpa / seaLevelPressureHpa, 0.190294957)))
        .toDouble();
  }

  void _checkPositiveFinite(double value, String name) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(
          value, name, 'Must be a positive finite number.');
    }
  }
}

class AltitudeSample {
  const AltitudeSample({
    required this.pressureHpa,
    required this.altitudeMeters,
    required this.aglMeters,
  });

  final double pressureHpa;
  final double altitudeMeters;
  final double? aglMeters;
}

class AglEngine {
  AglEngine({
    PressureAltitudeCalculator calculator = const PressureAltitudeCalculator(),
  }) : _calculator = calculator;

  final PressureAltitudeCalculator _calculator;
  double? _groundAltitudeMeters;

  double? get groundAltitudeMeters => _groundAltitudeMeters;
  bool get isCalibrated => _groundAltitudeMeters != null;

  AltitudeSample calibrateGroundFromPressure(double pressureHpa) {
    final altitudeMeters = _calculator.altitudeMetersFromPressure(pressureHpa);
    _groundAltitudeMeters = altitudeMeters;

    return AltitudeSample(
      pressureHpa: pressureHpa,
      altitudeMeters: altitudeMeters,
      aglMeters: 0,
    );
  }

  AltitudeSample sampleFromPressure(double pressureHpa) {
    final altitudeMeters = _calculator.altitudeMetersFromPressure(pressureHpa);
    final groundAltitudeMeters = _groundAltitudeMeters;

    return AltitudeSample(
      pressureHpa: pressureHpa,
      altitudeMeters: altitudeMeters,
      aglMeters: groundAltitudeMeters == null
          ? null
          : altitudeMeters - groundAltitudeMeters,
    );
  }

  void resetCalibration() {
    _groundAltitudeMeters = null;
  }
}
