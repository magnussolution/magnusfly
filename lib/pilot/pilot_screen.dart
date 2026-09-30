import 'dart:async';

import 'package:flutter/material.dart';

import '../api/magnusfly_api_client.dart';
import '../flight/altitude_engine.dart';
import '../flight/variometer_engine.dart';
import '../l10n/generated/app_localizations.dart';
import 'pilot_background_engine.dart';
import 'pilot_profile_store.dart';

class PilotScreen extends StatefulWidget {
  PilotScreen({
    MagnusFlyApiClient? apiClient,
    PilotBackgroundEngine? pilotBackgroundEngine,
    this.profileStore = const PilotProfileStore(),
    super.key,
  })  : apiClient = apiClient ?? MagnusFlyApiClient(),
        pilotBackgroundEngine =
            pilotBackgroundEngine ?? PilotBackgroundEngine();

  final MagnusFlyApiClient apiClient;
  final PilotBackgroundEngine pilotBackgroundEngine;
  final PilotProfileStore profileStore;

  @override
  State<PilotScreen> createState() => _PilotScreenState();
}

class _PilotScreenState extends State<PilotScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final AglEngine _aglEngine = AglEngine();
  final VariometerEngine _variometerEngine =
      VariometerEngine(smoothingFactor: 0.35);
  StreamSubscription<PilotBarometerSample>? _subscription;
  PilotBarometerSample? _lastBarometerSample;
  AltitudeSample? _lastAltitudeSample;
  VarioSample? _lastVarioSample;
  String? _pilotToken;
  Object? _error;
  bool _isStarting = false;
  bool _isAccepting = false;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProfile());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    unawaited(_subscription?.cancel());
    unawaited(widget.pilotBackgroundEngine.stop());
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await widget.profileStore.load();
    if (!mounted || profile == null) {
      return;
    }

    setState(() {
      _usernameController.text = profile.username;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _countryController.text = profile.country;
    });
  }

  Future<PilotProfile?> _saveProfileToDatabase() async {
    final profile = PilotProfile(
      username: _usernameController.text.trim().toLowerCase(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      country: _countryController.text.trim(),
    );

    if (profile.username.isEmpty ||
        profile.name.isEmpty ||
        profile.email.isEmpty ||
        profile.country.isEmpty) {
      setState(() {
        _error = AppLocalizations.of(context).pilotProfileRequired;
      });
      return null;
    }

    final savedProfile = await widget.apiClient.registerPilot(profile);
    await widget.profileStore.save(savedProfile);

    return savedProfile;
  }

  Future<void> _acceptSessionAndStart() async {
    setState(() {
      _isAccepting = true;
      _error = null;
    });

    try {
      final profile = await _saveProfileToDatabase();
      if (profile == null) {
        setState(() {
          _isAccepting = false;
        });
        return;
      }

      final acceptedSession = await widget.apiClient.acceptSession(
        pilotUsername: profile.username,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _pilotToken = acceptedSession.pilotToken;
        _isAccepting = false;
      });
      await _startPilotTransmission();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAccepting = false;
        _error = error;
      });
    }
  }

  Future<void> _startPilotTransmission() async {
    try {
      setState(() {
        _isStarting = true;
      });
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
    final verticalSpeed = varioSample.verticalSpeedMetersPerSecond;
    final aglMeters = altitudeSample.aglMeters;
    final pilotToken = _pilotToken;

    if (pilotToken != null && verticalSpeed != null && aglMeters != null) {
      unawaited(
        widget.apiClient.sendPilotTelemetry(
          pilotToken: pilotToken,
          varioMps: verticalSpeed,
          aglM: aglMeters,
          pressureHpa: sample.pressureHpa,
          relativeAltitudeM: sample.relativeAltitudeMeters,
          timestampMillis: sample.timestamp.millisecondsSinceEpoch,
        ),
      );
    }

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
      _pilotToken = null;
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
            if (!_isRunning) ...[
              _PilotProfileForm(
                usernameController: _usernameController,
                nameController: _nameController,
                emailController: _emailController,
                countryController: _countryController,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isAccepting ? null : _acceptSessionAndStart,
                icon: const Icon(Icons.link_outlined),
                label: Text(
                  _isAccepting
                      ? l10n.pilotAcceptingSession
                      : l10n.pilotAcceptSession,
                ),
              ),
              const SizedBox(height: 24),
            ],
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

class _PilotProfileForm extends StatelessWidget {
  const _PilotProfileForm({
    required this.usernameController,
    required this.nameController,
    required this.emailController,
    required this.countryController,
  });

  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController countryController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        TextField(
          controller: usernameController,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.pilotUsernameLabel,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.pilotNameLabel,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.pilotEmailLabel,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: countryController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l10n.pilotCountryLabel,
          ),
        ),
      ],
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
