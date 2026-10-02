import 'dart:math' as math;

class TowPosition {
  const TowPosition(this.latitude, this.longitude, this.accuracy, this.time);
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime time;

  bool usable(DateTime now) =>
      latitude.isFinite &&
      longitude.isFinite &&
      accuracy.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      accuracy >= 0 &&
      accuracy <= 20 &&
      now.difference(time).inMilliseconds >= 0 &&
      now.difference(time).inMilliseconds <= 3000;

  Map<String, Object> toJson(DateTime now) => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'ageMs': math.max(0, now.difference(time).inMilliseconds),
      };
}

enum AngleBand { low, reference, high }

class TowGeometry {
  const TowGeometry(this.horizontalMeters, this.ropeMeters, this.angleDegrees);
  final double horizontalMeters;
  final double ropeMeters;
  final double angleDegrees;

  AngleBand get band => angleDegrees < 30
      ? AngleBand.low
      : angleDegrees <= 50
          ? AngleBand.reference
          : AngleBand.high;

  static TowGeometry? calculate(
      {required TowPosition? pilot,
      required TowPosition? driver,
      required double aglMeters,
      required DateTime now}) {
    if (pilot == null ||
        driver == null ||
        !pilot.usable(now) ||
        !driver.usable(now) ||
        !aglMeters.isFinite ||
        aglMeters < 0 ||
        pilot.time.difference(driver.time).inMilliseconds.abs() > 2000) {
      return null;
    }
    const radians = math.pi / 180;
    final dLat = (pilot.latitude - driver.latitude) * radians;
    final dLon = (pilot.longitude - driver.longitude) * radians;
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(pilot.latitude * radians) *
            math.cos(driver.latitude * radians) *
            math.pow(math.sin(dLon / 2), 2);
    final distance = 6371000 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
    // Near launch, uncertainty can dominate the triangle entirely.
    final rope = math.sqrt(distance * distance + aglMeters * aglMeters);
    if (rope < math.max(10, 2 * (pilot.accuracy + driver.accuracy))) {
      return null;
    }
    return TowGeometry(
        distance, rope, math.atan2(aglMeters, distance) / radians);
  }
}

class AngleSmoother {
  double? value;
  int trend = 0;
  void reset() {
    value = null;
    trend = 0;
  }

  double update(double angle) {
    final previous = value;
    value = previous == null ? angle : previous + 0.4 * (angle - previous);
    trend = previous == null || (value! - previous).abs() < 0.3
        ? 0
        : value! > previous
            ? 1
            : -1;
    return value!;
  }
}
