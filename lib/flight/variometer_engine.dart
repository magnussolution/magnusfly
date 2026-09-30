class VarioSample {
  const VarioSample({
    required this.altitudeMeters,
    required this.timestamp,
    required this.verticalSpeedMetersPerSecond,
  });

  final double altitudeMeters;
  final DateTime timestamp;
  final double? verticalSpeedMetersPerSecond;
}

class VariometerEngine {
  VariometerEngine({
    this.smoothingFactor = 1,
  }) {
    if (!smoothingFactor.isFinite ||
        smoothingFactor <= 0 ||
        smoothingFactor > 1) {
      throw ArgumentError.value(
        smoothingFactor,
        'smoothingFactor',
        'Must be greater than 0 and less than or equal to 1.',
      );
    }
  }

  final double smoothingFactor;
  VarioSample? _lastSample;

  VarioSample sample({
    required double altitudeMeters,
    required DateTime timestamp,
  }) {
    _checkFinite(altitudeMeters, 'altitudeMeters');

    final previousSample = _lastSample;
    if (previousSample == null) {
      return _lastSample = VarioSample(
        altitudeMeters: altitudeMeters,
        timestamp: timestamp,
        verticalSpeedMetersPerSecond: null,
      );
    }

    final elapsedSeconds =
        timestamp.difference(previousSample.timestamp).inMicroseconds /
            Duration.microsecondsPerSecond;

    if (elapsedSeconds <= 0) {
      throw ArgumentError.value(
        timestamp,
        'timestamp',
        'Must be after the previous sample timestamp.',
      );
    }

    final rawVerticalSpeed =
        (altitudeMeters - previousSample.altitudeMeters) / elapsedSeconds;
    final previousVerticalSpeed = previousSample.verticalSpeedMetersPerSecond;
    final verticalSpeed = previousVerticalSpeed == null
        ? rawVerticalSpeed
        : (smoothingFactor * rawVerticalSpeed) +
            ((1 - smoothingFactor) * previousVerticalSpeed);

    return _lastSample = VarioSample(
      altitudeMeters: altitudeMeters,
      timestamp: timestamp,
      verticalSpeedMetersPerSecond: verticalSpeed,
    );
  }

  void reset() {
    _lastSample = null;
  }

  void _checkFinite(double value, String name) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, name, 'Must be a finite number.');
    }
  }
}
