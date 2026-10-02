import 'dart:math' as math;

int telemetryAgeMs(
    {required int receivedAgeMs,
    required int elapsedMs,
    required int requestMs,
    required int? capturedAtMs,
    required int nowMs}) {
  final transportAge = receivedAgeMs + elapsedMs + requestMs;
  if (capturedAtMs == null) return transportAge;
  final sampleAge = nowMs - capturedAtMs;
  // A substantially future timestamp is not a reliable live measurement.
  if (sampleAge < -2000) return 2147483647;
  return math.max(transportAge, sampleAge);
}
