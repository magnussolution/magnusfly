import 'dart:async';
import 'package:flutter/material.dart';
import '../api/magnusfly_api_client.dart';
import '../flight/tow_geometry.dart';
import '../flight/tow_location.dart';
import '../flight/tow_permissions.dart';
import '../flight/tow_store.dart';
import '../flight/telemetry_age.dart';
import '../l10n/generated/app_localizations.dart';
import 'driver_vario_audio.dart';
import 'tow_history_screen.dart';

class DriverScreen extends StatefulWidget {
  DriverScreen(
      {this.username = 'local',
      this.store,
      this.location,
      MagnusFlyApiClient? apiClient,
      DriverVarioAudio? varioAudio,
      super.key})
      : apiClient = apiClient ?? MagnusFlyApiClient(),
        varioAudio = varioAudio ?? DriverVarioAudio();
  final String username;
  final TowStore? store;
  final TowLocation? location;
  final MagnusFlyApiClient apiClient;
  final DriverVarioAudio varioAudio;
  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final _username = TextEditingController();
  late final _location = widget.location ?? TowLocation();
  final _smoother = AngleSmoother();
  late final _store = widget.store ?? TowStore(widget.username);
  final _receivedClock = Stopwatch();
  final _activeClock = Stopwatch();
  Map<String, dynamic>? _session;
  DriverTelemetrySnapshot? _snapshot;
  TowGeometry? _geometry;
  Timer? _pollTimer, _tickTimer;
  bool _busy = true, _pollBusy = false, _finishing = false, _ended = false;
  bool _muted = false, _lost = false, _audio = true, _historyError = false;
  String? _error;
  int _requestMs = 0, _lastRecord = 0;
  int? _lastAudioId, _lastGeometryId;
  bool _recording = false;

  int? get _age => _snapshot?.telemetry == null
      ? null
      : telemetryAgeMs(
          receivedAgeMs: _snapshot!.telemetry!.receivedAgeMs,
          elapsedMs: _receivedClock.elapsedMilliseconds,
          requestMs: _requestMs,
          capturedAtMs: _snapshot!.telemetry!.timestampMillis,
          nowMs: DateTime.now().millisecondsSinceEpoch);
  bool get _fresh =>
      _session != null &&
      !_ended &&
      !_finishing &&
      _age != null &&
      _age! <= 3000;
  String get _code => _session!['code'] as String;

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  Future<void> _restore() async {
    try {
      _session = await _store.session('driver');
      if (_session != null) {
        _finishing = _session!['finishing'] == true;
        if (!_finishing && mounted) {
          final gps = await prepareTowLocation(context, _location);
          if (gps && mounted) {
            _location.start(pilot: false, notification: 'MagnusFly');
          }
        }
        _startTimers();
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _busy = false);
  }

  void _startTimers() {
    _pollTimer?.cancel();
    _tickTimer?.cancel();
    _pollTimer = Timer.periodic(
        const Duration(milliseconds: 800), (_) => unawaited(_poll()));
    _tickTimer =
        Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    unawaited(_poll());
  }

  Future<void> _create() async {
    if (_username.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final gps = await prepareTowLocation(context, _location);
      final result = await widget.apiClient.createSession(
          pilotUsername: _username.text.trim().replaceFirst(RegExp(r'^@'), ''));
      _session = {
        'token': result.driverToken,
        'code': result.code,
        'pilot': result.pilotUsername,
        'finishing': false
      };
      await _store.saveSession('driver', _session);
      _snapshot = null;
      _ended = false;
      _finishing = false;
      _muted = false;
      _lost = false;
      _activeClock.reset();
      _activeClock.stop();
      _smoother.reset();
      _lastAudioId = null;
      _lastGeometryId = null;
      _geometry = null;
      if (gps && mounted) {
        _location.start(pilot: false, notification: 'MagnusFly');
      }
      _startTimers();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _poll() async {
    if (_pollBusy || _session == null) return;
    _pollBusy = true;
    try {
      final token = _session!['token'] as String;
      if (_finishing) await widget.apiClient.finishSession(token);
      final watch = Stopwatch()..start();
      final snapshot = await widget.apiClient.latestTelemetry(token);
      if (!mounted) return;
      _requestMs = watch.elapsedMilliseconds;
      _snapshot = snapshot;
      _receivedClock.reset();
      _receivedClock.start();
      _error = null;
      if (snapshot.status == 'active' && !_activeClock.isRunning) {
        _activeClock.start();
      }
      if (snapshot.status == 'ended') {
        _finishing = true;
        widget.varioAudio.dispose();
        await _location.stop();
        if (snapshot.pilotStopped) {
          await _store.saveSession('driver', null);
          _session = null;
          _finishing = false;
          _ended = true;
          _pollTimer?.cancel();
          _tickTimer?.cancel();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _pollBusy = false;
      if (mounted) {
        _tick();
        setState(() {});
      }
    }
  }

  void _tick() {
    if (!mounted || _session == null) return;
    final telemetry = _snapshot?.telemetry;
    final lost = !_finishing &&
        _activeClock.isRunning &&
        (!_fresh && (_age != null || _activeClock.elapsedMilliseconds > 3000));
    if (lost != _lost) {
      _lost = lost;
      if (!lost) _muted = false;
      _lastAudioId = null;
    }
    if (!_finishing) widget.varioAudio.connectionLost(_lost, muted: _muted);
    if (!_fresh) {
      widget.varioAudio.stop();
      _geometry = null;
      _smoother.reset();
      _lastGeometryId = null;
    } else if (telemetry != null) {
      if (_lastAudioId != telemetry.id) {
        widget.varioAudio.update(
            varioMetersPerSecond: telemetry.varioMps, telemetryFresh: true);
        _lastAudioId = telemetry.id;
      }
      final now = DateTime.now();
      final geometry = TowGeometry.calculate(
          pilot: telemetry.positionAt(now, _age!),
          driver: _location.latest,
          aglMeters: telemetry.aglM,
          now: now);
      if (geometry == null) {
        _geometry = null;
        _smoother.reset();
        _lastGeometryId = null;
      } else if (_lastGeometryId != telemetry.id) {
        _geometry = TowGeometry(geometry.horizontalMeters, geometry.ropeMeters,
            _smoother.update(geometry.angleDegrees));
        _lastGeometryId = telemetry.id;
      }
    }
    if (_activeClock.isRunning && !_finishing) unawaited(_record());
    setState(() {});
  }

  Future<void> _record() async {
    final now = DateTime.now();
    if (_recording ||
        now.millisecondsSinceEpoch - _lastRecord < 1000 ||
        _session == null) {
      return;
    }
    _recording = true;
    _lastRecord = now.millisecondsSinceEpoch;
    try {
      await _store.append(_code, {
        'time': now.toIso8601String(),
        'pilot': _session!['pilot'],
        'agl': _fresh ? _snapshot?.telemetry?.aglM : null,
        'vario': _fresh ? _snapshot?.telemetry?.varioMps : null,
        'angle': _geometry?.angleDegrees,
        'rope': _geometry?.ropeMeters,
        'distance': _geometry?.horizontalMeters,
        'lost': _lost,
        'ageMs': _age,
        'gps': _geometry != null
      });
      _historyError = false;
    } catch (_) {
      _historyError = true;
    } finally {
      _recording = false;
    }
  }

  Future<void> _finish() async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(l.towFinish),
                content: Text(l.towConfirmFinish),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.cancelButton)),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l.towConfirm))
                ]));
    if (confirm != true || _session == null) return;
    _session!['finishing'] = true;
    _session!['endedAt'] = DateTime.now().toIso8601String();
    _finishing = true;
    widget.varioAudio.dispose();
    await _location.stop();
    try {
      await _store.saveSession('driver', _session);
      await _store.append(_code, {
        'time': _session!['endedAt'],
        'event': 'manual_finish',
        'pilot': _session!['pilot']
      });
    } catch (_) {
      _historyError = true;
    }
    if (mounted) setState(() {});
    await _poll();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tickTimer?.cancel();
    _username.dispose();
    widget.varioAudio.dispose();
    unawaited(_location.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = _snapshot?.telemetry;
    final status = _finishing
        ? l.towFinishing
        : _lost
            ? l.towLost
            : _ended
                ? l.towEnded
                : _session == null
                    ? l.driverWaitingForSession
                    : _snapshot?.status == 'active'
                        ? l.driverReceivingTelemetry
                        : l.driverWaitingForPilot;
    final color = !_fresh || _geometry == null
        ? Colors.grey
        : switch (_geometry!.band) {
            AngleBand.low => Colors.orange.shade800,
            AngleBand.reference => Colors.green.shade700,
            AngleBand.high => Colors.red.shade700,
          };
    return PopScope(
        canPop: _session == null && !_busy,
        child: Scaffold(
          appBar: AppBar(title: Text(l.driverScreenTitle), actions: [
            IconButton(
                tooltip: l.towHistory,
                icon: const Icon(Icons.history),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => TowHistoryScreen(store: _store)))),
          ]),
          body: SafeArea(
              child: ListView(padding: const EdgeInsets.all(20), children: [
            Row(children: [
              Icon(_lost ? Icons.wifi_off : Icons.sensors,
                  color: _lost ? Colors.red : null),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(status,
                      style: Theme.of(context).textTheme.titleMedium))
            ]),
            if (_error != null)
              Text(l.driverConnectionError,
                  style: const TextStyle(color: Colors.red)),
            if (_historyError)
              Text(l.towHistoryError,
                  style: const TextStyle(color: Colors.red)),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            if (_session == null) ...[
              TextField(
                  controller: _username,
                  decoration: InputDecoration(
                      labelText: l.driverPilotUsernameLabel,
                      border: const OutlineInputBorder())),
              const SizedBox(height: 12),
              FilledButton.icon(
                  onPressed: _busy ? null : _create,
                  icon: const Icon(Icons.link),
                  label: Text(l.driverCreateSession)),
            ] else
              Text('@${_session!['pilot']} · ${_session!['code']}'),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 3 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                _Metric(l.aglLabel, t?.aglM.toStringAsFixed(0) ?? '--', 'm',
                    width, _fresh ? null : Colors.grey),
                _Metric(l.varioLabel, t?.varioMps.toStringAsFixed(1) ?? '--',
                    'm/s', width, _fresh ? null : Colors.grey),
                _Metric(
                    l.towAngle,
                    _geometry?.angleDegrees.toStringAsFixed(0) ?? '--',
                    _smoother.trend > 0
                        ? '° ↑'
                        : _smoother.trend < 0
                            ? '° ↓'
                            : '°',
                    width,
                    color),
                _Metric(
                    l.towRope,
                    _geometry == null
                        ? '--'
                        : '≈ ${_geometry!.ropeMeters.round()}',
                    'm',
                    width,
                    color),
                _Metric(
                    l.towDistance,
                    _geometry?.horizontalMeters.toStringAsFixed(0) ?? '--',
                    'm',
                    width,
                    color),
                _Metric(
                    l.delayLabel,
                    _age == null ? '--' : (_age! / 1000).toStringAsFixed(1),
                    's',
                    width,
                    _fresh ? null : Colors.grey),
              ]);
            }),
            if (_session != null &&
                !_finishing &&
                _fresh &&
                _geometry == null) ...[
              const SizedBox(height: 12),
              Text(l.towGps),
              TextButton.icon(
                  onPressed: () async {
                    await _location.stop();
                    if (!context.mounted) return;
                    final gps = await prepareTowLocation(context, _location);
                    if (gps && mounted && !_finishing && _session != null) {
                      _location.start(pilot: false, notification: 'MagnusFly');
                    }
                  },
                  icon: const Icon(Icons.gps_fixed),
                  label: Text(l.towRetry)),
            ],
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.driverVarioSoundLabel),
                value: _audio,
                onChanged: (value) {
                  setState(() => _audio = value);
                  widget.varioAudio.enabled = value;
                  _lastAudioId = null;
                  _tick();
                }),
            if (_lost && !_finishing)
              SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.towMute),
                  value: _muted,
                  onChanged: (v) {
                    setState(() => _muted = v);
                    widget.varioAudio.connectionLost(true, muted: v);
                  }),
            if (_session != null)
              FilledButton.icon(
                  onPressed: _finishing ? null : _finish,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(l.towFinish)),
          ])),
        ));
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.unit, this.width, this.color);
  final String label, value, unit;
  final double width;
  final Color? color;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 130),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(
                color: color ?? Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: color))),
          Text(unit, style: TextStyle(color: color)),
        ]),
      ));
}
