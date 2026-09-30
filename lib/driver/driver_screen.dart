import 'dart:async';

import 'package:flutter/material.dart';

import '../api/magnusfly_api_client.dart';
import '../l10n/generated/app_localizations.dart';

class DriverScreen extends StatefulWidget {
  DriverScreen({
    MagnusFlyApiClient? apiClient,
    super.key,
  }) : apiClient = apiClient ?? MagnusFlyApiClient();

  final MagnusFlyApiClient apiClient;

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final TextEditingController _pilotUsernameController =
      TextEditingController();
  CreatedSession? _session;
  DriverTelemetrySnapshot? _snapshot;
  Timer? _pollTimer;
  Object? _error;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pilotUsernameController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _createSession() async {
    final pilotUsername = _pilotUsernameController.text.trim().toLowerCase();
    if (pilotUsername.isEmpty) {
      setState(() {
        _error = AppLocalizations.of(context).driverPilotUsernameRequired;
      });
      return;
    }

    setState(() {
      _isStarting = true;
      _error = null;
    });

    try {
      final session = await widget.apiClient.createSession(
        pilotUsername: pilotUsername,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _session = session;
        _isStarting = false;
        _error = null;
      });
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 800),
        (_) => unawaited(_pollLatestTelemetry()),
      );
      unawaited(_pollLatestTelemetry());
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isStarting = false;
        _error = error;
      });
    }
  }

  Future<void> _pollLatestTelemetry() async {
    final session = _session;
    if (session == null) {
      return;
    }

    try {
      final snapshot = await widget.apiClient.latestTelemetry(
        session.driverToken,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final telemetry = _snapshot?.telemetry;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driverScreenTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _DriverStatusBanner(
              isStarting: _isStarting,
              session: _session,
              snapshot: _snapshot,
              error: _error,
            ),
            const SizedBox(height: 24),
            if (_session == null) ...[
              TextField(
                controller: _pilotUsernameController,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.driverPilotUsernameLabel,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isStarting ? null : _createSession,
                icon: const Icon(Icons.play_arrow_outlined),
                label: Text(l10n.driverCreateSession),
              ),
              const SizedBox(height: 24),
            ],
            if (_session != null) _SessionCodePanel(code: _session!.code),
            const SizedBox(height: 24),
            _DriverMetricGrid(
              varioMetersPerSecond: telemetry?.varioMps,
              aglMeters: telemetry?.aglM,
              receivedAgeMs: telemetry?.receivedAgeMs,
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverStatusBanner extends StatelessWidget {
  const _DriverStatusBanner({
    required this.isStarting,
    required this.session,
    required this.snapshot,
    required this.error,
  });

  final bool isStarting;
  final CreatedSession? session;
  final DriverTelemetrySnapshot? snapshot;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isStale = (snapshot?.telemetry?.receivedAgeMs ?? 0) > 3000;
    final (icon, text, color) = switch ((isStarting, session, error, isStale)) {
      (_, _, final Object error, _) => (
          Icons.error_outline,
          '${l10n.driverConnectionError}: $error',
          colorScheme.error,
        ),
      (true, _, _, _) => (
          Icons.sync_outlined,
          l10n.driverCreatingSession,
          colorScheme.primary,
        ),
      (_, null, _, _) => (
          Icons.pause_circle_outline,
          l10n.driverWaitingForSession,
          colorScheme.secondary,
        ),
      (_, _, _, true) => (
          Icons.warning_amber_outlined,
          l10n.driverTelemetryDelayed,
          colorScheme.error,
        ),
      (_, final CreatedSession _, _, _) when snapshot?.telemetry == null => (
          Icons.hourglass_empty_outlined,
          l10n.driverWaitingForPilot,
          colorScheme.primary,
        ),
      _ => (
          Icons.sensors_outlined,
          l10n.driverReceivingTelemetry,
          colorScheme.primary,
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

class _SessionCodePanel extends StatelessWidget {
  const _SessionCodePanel({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.driverSessionCodeLabel, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        SelectableText(
          code,
          style: textTheme.displayMedium?.copyWith(
            fontFeatures: const [],
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _DriverMetricGrid extends StatelessWidget {
  const _DriverMetricGrid({
    required this.varioMetersPerSecond,
    required this.aglMeters,
    required this.receivedAgeMs,
  });

  final double? varioMetersPerSecond;
  final double? aglMeters;
  final int? receivedAgeMs;

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
        _DriverMetricTile(
          label: l10n.varioLabel,
          value: _formatSigned(varioMetersPerSecond),
          unit: l10n.metersPerSecondUnit,
        ),
        _DriverMetricTile(
          label: l10n.aglLabel,
          value: _formatNumber(aglMeters),
          unit: l10n.metersUnit,
        ),
        _DriverMetricTile(
          label: l10n.delayLabel,
          value: receivedAgeMs == null ? '--' : receivedAgeMs.toString(),
          unit: l10n.millisecondsUnit,
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

class _DriverMetricTile extends StatelessWidget {
  const _DriverMetricTile({
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
