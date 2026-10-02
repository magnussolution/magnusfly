import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/flight/telemetry_age.dart';

void main() {
  test('age keeps advancing during failed requests', () {
    expect(
        telemetryAgeMs(
            receivedAgeMs: 500,
            elapsedMs: 4000,
            requestMs: 100,
            capturedAtMs: null,
            nowMs: 10000),
        4600);
  });
  test('late delivery cannot make an old sample fresh', () {
    expect(
        telemetryAgeMs(
            receivedAgeMs: 0,
            elapsedMs: 0,
            requestMs: 20,
            capturedAtMs: 1000,
            nowMs: 10000),
        9000);
  });
  test('clock skew is treated as unavailable, not live', () {
    expect(
        telemetryAgeMs(
            receivedAgeMs: 0,
            elapsedMs: 0,
            requestMs: 0,
            capturedAtMs: 20000,
            nowMs: 10000),
        greaterThan(3000));
  });
}
