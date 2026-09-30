import 'package:sensors_plus/sensors_plus.dart';

class DeviceBarometerSource {
  const DeviceBarometerSource({
    this.samplingPeriod = SensorInterval.normalInterval,
  });

  final Duration samplingPeriod;

  Stream<double> pressureHpaStream() {
    return barometerEventStream(
      samplingPeriod: samplingPeriod,
    ).map((event) => event.pressure);
  }
}
