import 'dart:async';
import 'package:flutter/material.dart';
import '../api/magnusfly_api_client.dart';
import '../flight/altitude_engine.dart';
import '../flight/variometer_engine.dart';
import '../flight/tow_location.dart';
import '../flight/tow_permissions.dart';
import '../flight/tow_store.dart';
import '../l10n/generated/app_localizations.dart';
import 'pilot_background_engine.dart';

class PilotScreen extends StatefulWidget {
  PilotScreen(
      {required this.profile,
      MagnusFlyApiClient? apiClient,
      PilotBackgroundEngine? pilotBackgroundEngine,
      super.key})
      : apiClient = apiClient ?? MagnusFlyApiClient(),
        pilotBackgroundEngine =
            pilotBackgroundEngine ?? PilotBackgroundEngine();
  final PilotProfile profile;
  final MagnusFlyApiClient apiClient;
  final PilotBackgroundEngine pilotBackgroundEngine;
  @override
  State<PilotScreen> createState() => _PilotScreenState();
}

class _PilotScreenState extends State<PilotScreen> {
  final _agl = AglEngine();
  final _vario = VariometerEngine(smoothingFactor: 0.35);
  final _location = TowLocation();
  late final TowStore _store = TowStore(widget.profile.username);
  Map<String, dynamic>? _session;
  StreamSubscription<PilotBarometerSample>? _samples;
  Timer? _control;
  AltitudeSample? _altitude;
  VarioSample? _vertical;
  PilotBarometerSample? _latest;
  bool _running = false, _busy = true, _requesting = false, _sending = false;
  bool _stopping = false, _ended = false;
  String? _error;
  int _lastSent = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  Future<void> _restore() async {
    try {
      _session = await _store.session('pilot');
      if (_session != null) {
        _control = Timer.periodic(
            const Duration(seconds: 1), (_) => unawaited(_check()));
        await _check();
        if (_session != null && _session!['stopped'] != true && mounted) {
          final allowed = await prepareTowLocation(context, _location);
          if (mounted) await _start(allowed);
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _accept() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _ended = false;
    });
    try {
      final allowed = await prepareTowLocation(context, _location);
      if (!mounted) return;
      if (!await widget.pilotBackgroundEngine.isAvailable()) {
        throw StateError(l.pilotBarometerUnavailable);
      }
      final accepted = await widget.apiClient
          .acceptSession(pilotUsername: widget.profile.username);
      _session = {'token': accepted.pilotToken};
      await _store.saveSession('pilot', _session);
      _control?.cancel();
      _control = Timer.periodic(
          const Duration(seconds: 1), (_) => unawaited(_check()));
      if (mounted) await _start(allowed);
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _start(bool gps) async {
    _latest = null;
    _altitude = null;
    _vertical = null;
    _lastSent = 0;
    _agl.resetCalibration();
    _vario.reset();
    final ground = _session?['groundPressure'] as num?;
    if (ground != null) _agl.calibrateGroundFromPressure(ground.toDouble());
    _running = true;
    if (gps) {
      _location.start(
          pilot: true,
          notification: AppLocalizations.of(context).pilotTransmissionActive);
    }
    _samples = widget.pilotBackgroundEngine.barometerSamples().listen(_sample,
        onError: (Object e) {
      if (mounted) setState(() => _error = e.toString());
    });
    try {
      await widget.pilotBackgroundEngine.start();
    } catch (_) {
      _running = false;
      await _samples?.cancel();
      await _location.stop();
      rethrow;
    }
    if (mounted) setState(() {});
  }

  void _sample(PilotBarometerSample sample) {
    if (!_running || _stopping) return;
    if (_latest != null && !sample.timestamp.isAfter(_latest!.timestamp)) {
      return;
    }
    _latest = sample;
    if (!_agl.isCalibrated) {
      _agl.calibrateGroundFromPressure(sample.pressureHpa);
      _session!['groundPressure'] = sample.pressureHpa;
      unawaited(_store.saveSession('pilot', _session).catchError((Object e) {
        if (mounted) setState(() => _error = e.toString());
      }));
    }
    _altitude = _agl.sampleFromPressure(sample.pressureHpa);
    _vertical = _vario.sample(
        altitudeMeters: _altitude!.altitudeMeters, timestamp: sample.timestamp);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (!_sending && now - _lastSent >= 800) {
      _lastSent = now;
      unawaited(_send(sample));
    }
    if (mounted) setState(() {});
  }

  Future<void> _send(PilotBarometerSample sample) async {
    final token = _session?['token'] as String?;
    if (token == null) return;
    _sending = true;
    try {
      final status = await widget.apiClient.sendPilotTelemetry(
          pilotToken: token,
          varioMps: _vertical?.verticalSpeedMetersPerSecond ?? 0,
          aglM: _altitude!.aglMeters!,
          pressureHpa: sample.pressureHpa,
          relativeAltitudeM: sample.relativeAltitudeMeters,
          timestampMillis: sample.timestamp.millisecondsSinceEpoch,
          location: _location.latest);
      if (status == 'ended') {
        await _shutdown();
      } else {
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _sending = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _check() async {
    if (_requesting || _session == null || _stopping) return;
    _requesting = true;
    try {
      final status = await widget.apiClient.pilotStatus(
          _session!['token'] as String,
          stopped: _session!['stopped'] == true);
      if (status == 'ended') {
        if (_session!['stopped'] == true) {
          await _store.saveSession('pilot', null);
          _session = null;
          _control?.cancel();
          _ended = true;
        } else {
          await _shutdown();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _requesting = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _shutdown() async {
    if (_stopping || _session == null) return;
    _stopping = true;
    _running = false;
    try {
      await widget.pilotBackgroundEngine.stop();
      await _location.stop();
      await _samples?.cancel();
      _samples = null;
      _session!['stopped'] = true;
      await _store.saveSession('pilot', _session);
      _ended = true;
      // Confirmation is retried by the control timer only after sensors stop.
    } finally {
      _stopping = false;
    }
  }

  @override
  void dispose() {
    _control?.cancel();
    unawaited(_samples?.cancel());
    unawaited(_location.stop());
    unawaited(widget.pilotBackgroundEngine.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
        canPop: _session == null && !_busy,
        child: Scaffold(
          appBar: AppBar(title: Text(l.pilotScreenTitle)),
          body: SafeArea(
              child: ListView(padding: const EdgeInsets.all(24), children: [
            Text('@${widget.profile.username}'),
            const SizedBox(height: 16),
            Text(
                _ended
                    ? l.towEnded
                    : _running
                        ? l.pilotTransmissionActive
                        : l.pilotTransmissionStopped,
                style: Theme.of(context).textTheme.titleLarge),
            if (_error != null)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('${l.pilotTransmissionError}: $_error')),
            if (_busy) const LinearProgressIndicator(),
            if (_session == null && !_busy)
              FilledButton.icon(
                  onPressed: _accept,
                  icon: const Icon(Icons.link),
                  label: Text(l.pilotAcceptSession)),
            if (_session != null && !_running && !_ended && !_busy)
              FilledButton.icon(
                  onPressed: () async {
                    setState(() => _busy = true);
                    try {
                      await _check();
                      if (_session != null &&
                          _session!['stopped'] != true &&
                          context.mounted) {
                        final allowed =
                            await prepareTowLocation(context, _location);
                        if (mounted) await _start(allowed);
                      }
                    } catch (e) {
                      _error = e.toString();
                    }
                    if (mounted) setState(() => _busy = false);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l.towContinue)),
            const SizedBox(height: 24),
            ListTile(
                title: Text(l.aglLabel),
                trailing: Text(
                    '${_altitude?.aglMeters?.toStringAsFixed(0) ?? '--'} m')),
            ListTile(
                title: Text(l.varioLabel),
                trailing: Text(
                    '${_vertical?.verticalSpeedMetersPerSecond?.toStringAsFixed(1) ?? '--'} m/s')),
            if (_running &&
                !(_location.latest?.usable(DateTime.now()) ?? false))
              Text(l.towGps),
          ])),
        ));
  }
}
