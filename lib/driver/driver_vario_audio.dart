import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class DriverVarioAudio {
  DriverVarioAudio({
    MethodChannel methodChannel = const MethodChannel(_channelName),
  }) : _methodChannel = methodChannel;

  static const _channelName = 'com.magnussolution.magnusfly/driver_vario_audio';

  final MethodChannel _methodChannel;
  Timer? _timer;
  double? _varioMetersPerSecond;
  bool _enabled = true;

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    if (!_enabled) {
      stop();
    } else {
      _reschedule();
    }
  }

  void update({
    required double? varioMetersPerSecond,
    required bool telemetryFresh,
  }) {
    _varioMetersPerSecond = telemetryFresh ? varioMetersPerSecond : null;
    _reschedule();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _varioMetersPerSecond = null;
  }

  void dispose() {
    stop();
  }

  void _reschedule() {
    _timer?.cancel();
    _timer = null;

    if (!_enabled) {
      return;
    }

    final vario = _varioMetersPerSecond;
    if (vario == null || vario.abs() < 0.15) {
      return;
    }

    final cadence = _cadenceFor(vario);
    _timer = Timer.periodic(cadence, (_) => unawaited(_playBeep(vario)));
    unawaited(_playBeep(vario));
  }

  Duration _cadenceFor(double vario) {
    if (vario > 0) {
      final milliseconds = 650 - (math.min(vario, 5) * 105);
      return Duration(milliseconds: milliseconds.round().clamp(120, 650));
    }

    return const Duration(milliseconds: 700);
  }

  Future<void> _playBeep(double vario) async {
    final isClimbing = vario > 0;
    final frequency = isClimbing
        ? 650 + (math.min(vario, 5) * 170)
        : 260 + (math.min(vario.abs(), 5) * 25);
    final durationMs = isClimbing ? 90 : 180;

    try {
      await _methodChannel.invokeMethod<void>('playBeep', {
        'frequencyHz': frequency,
        'durationMs': durationMs,
        'volume': isClimbing ? 0.8 : 0.45,
      });
    } on PlatformException {
      // Audio feedback should never interrupt the driver telemetry screen.
    } on MissingPluginException {
      // Keeps desktop/web test runs quiet until native audio is available there.
    }
  }
}
