import 'dart:async';

import 'package:flutter/material.dart';

import '../flight/altitude_engine.dart';
import '../flight/variometer_engine.dart';
import '../l10n/generated/app_localizations.dart';
import 'pilot_background_engine.dart';

class PilotScreen extends StatefulWidget {
  PilotScreen({
    PilotBackgroundEngine? pilotBackgroundEngine,
    super.key,
  }) : pilotBackgroundEngine = pilotBackgroundEngine ?? PilotBackgroundEngine();

  final PilotBackgroundEngine pilotBackgroundEngine;

  @override
  State<PilotScreen> createState() => _PilotScreenState();
}

class _PilotScreenState extends State<PilotScreen> {
  final AglEngine _aglEngine = AglEngine();
  final VariometerEngine _variometerEngine =
      VariometerEngine(smoothingFactor: 0.35);
  StreamSubscription<PilotBarometerSample>? _subscription;
  PilotBarometerSample? _lastBarometerSample;
  AltitudeSample? _lastAltitudeSample;
  VarioSample? _lastVarioSample;
  Object? _error;
  bool _isStarting = true;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    unawaited(_startPilotTransmission());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(widget.pilotBackgroundEngine.stop());
    super.dispose();
  }

  Future<void> _startPilotTransmission() async {
    try {
      final isAvailable = await widget.pilotBackgroundEngine.isAvailable();
      if (!isAvailable) {
        setState(() {
          _isStarting = false;
          _error = AppLocalizations.of(context).pilotBarometerUnavailable;
        });
        return;
      }

      _subscription = widget.pilotBackgroundEngine.barometerSamples().listen(
        _handleBarometerSample,
        onError: (Object error) {
          setState(() {
            _error = error;
          });
        },
      );
      await widget.pilotBackgroundEngine.start();

      setState(() {
        _isStarting = false;
        _isRunning = true;
      });
    } on Object catch (error) {
      setState(() {
        _isStarting = false;
        _isRunning = false;
        _error = error;
      });
    }
  }

  void _handleBarometerSample(PilotBarometerSample sample) {
    final altitudeSample = _aglEngine.isCalibrated
        ? _aglEngine.sampleFromPressure(sample.pressureHpa)
        : _aglEngine.calibrateGroundFromPressure(sample.pressureHpa);
    final varioSample = _variometerEngine.sample(
      altitudeMeters: altitudeSample.altitudeMeters,
      timestamp: sample.timestamp,
    );

    setState(() {
      _lastBarometerSample = sample;
      _lastAltitudeSample = altitudeSample;
      _lastVarioSample = varioSample;
      _error = null;
    });
  }

  Future<void> _stopPilotTransmission() async {
    await _subscription?.cancel();
    _subscription = null;
    await widget.pilotBackgroundEngine.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pilotScreenTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _StatusBanner(
              isStarting: _isStarting,
              isRunning: _isRunning,
              error: _error,
            ),
            const SizedBox(height: 24),
            _MetricGrid(
              varioMetersPerSecond:
                  _lastVarioSample?.verticalSpeedMetersPerSecond,
              aglMeters: _lastAltitudeSample?.aglMeters,
              pressureHpa: _lastBarometerSample?.pressureHpa,
              relativeAltitudeMeters:
                  _lastBarometerSample?.relativeAltitudeMeters,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isRunning ? _stopPilotTransmission : null,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(l10n.stopPilotTransmission),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.isStarting,
    required this.isRunning,
    required this.error,
  });

  final bool isStarting;
  final bool isRunning;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, text, color) = switch ((isStarting, isRunning, error)) {
      (_, _, final Object error) => (
          Icons.error_outline,
          '${l10n.pilotTransmissionError}: $error',
          colorScheme.error,
        ),
      (true, _, _) => (
          Icons.sync_outlined,
          l10n.pilotTransmissionStarting,
          colorScheme.primary,
        ),
      (_, true, _) => (
          Icons.sensors_outlined,
          l10n.pilotTransmissionActive,
          colorScheme.primary,
        ),
      _ => (
          Icons.pause_circle_outline,
          l10n.pilotTransmissionStopped,
          colorScheme.secondary,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.varioMetersPerSecond,
    required this.aglMeters,
    required this.pressureHpa,
    required this.relativeAltitudeMeters,
  });

  final double? varioMetersPerSecond;
  final double? aglMeters;
  final double? pressureHpa;
  final double? relativeAltitudeMeters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _MetricTile(
          label: l10n.varioLabel,
          value: _formatSigned(varioMetersPerSecond),
          unit: l10n.metersPerSecondUnit,
        ),
        _MetricTile(
          label: l10n.aglLabel,
          value: _formatNumber(aglMeters),
          unit: l10n.metersUnit,
        ),
        _MetricTile(
          label: l10n.pressureLabel,
          value: _formatNumber(pressureHpa),
          unit: l10n.hectopascalUnit,
        ),
        _MetricTile(
          label: l10n.relativeAltitudeLabel,
          value: _formatSigned(relativeAltitudeMeters),
          unit: l10n.metersUnit,
        ),
      ],
    );
  }

  String _formatNumber(double? value) {
    return value == null ? '--' : value.toStringAsFixed(1);
  }

  String _formatSigned(double? value) {
    if (value == null) {
      return '--';
    }

    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(value, style: textTheme.headlineMedium),
            Text(unit, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
