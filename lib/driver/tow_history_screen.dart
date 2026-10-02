import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../flight/tow_store.dart';
import '../l10n/generated/app_localizations.dart';

class TowHistoryScreen extends StatefulWidget {
  const TowHistoryScreen({required this.store, super.key});
  final TowStore store;
  @override
  State<TowHistoryScreen> createState() => _TowHistoryScreenState();
}

class _TowHistoryScreenState extends State<TowHistoryScreen> {
  late final Future<List<File>> _files = widget.store.files();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(title: Text(l.towHistory)),
        body: FutureBuilder<List<File>>(
            future: _files,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(l.towHistoryError));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return Center(child: Text(l.towEmpty));
              }
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final file = snapshot.data![i];
                    return ListTile(
                        leading: const Icon(Icons.paragliding),
                        title: Text(file.uri.pathSegments.last
                            .replaceAll('.jsonl', '')),
                        subtitle: Text(file
                            .lastModifiedSync()
                            .toLocal()
                            .toString()
                            .split('.')
                            .first),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) => _TowDetail(
                                    store: widget.store, file: file))));
                  });
            }));
  }
}

class _TowDetail extends StatefulWidget {
  const _TowDetail({required this.store, required this.file});
  final TowStore store;
  final File file;
  @override
  State<_TowDetail> createState() => _TowDetailState();
}

class _TowDetailState extends State<_TowDetail> {
  late final _records = widget.store.read(widget.file);
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(title: Text(l.towHistory)),
        body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _records,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(l.towHistoryError));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final rows = snapshot.data!;
              if (rows.isEmpty) return Center(child: Text(l.towEmpty));
              final ended = rows.any((r) => r['event'] == 'manual_finish');
              final start = DateTime.parse(rows.first['time'] as String);
              final end = DateTime.parse(rows.last['time'] as String);
              final duration = end.difference(start);
              var maxHeight = 0.0, gaps = 0;
              var wasLost = false;
              for (final r in rows) {
                maxHeight =
                    math.max(maxHeight, (r['agl'] as num?)?.toDouble() ?? 0);
                final lost = r['lost'] == true;
                if (lost && !wasLost) gaps++;
                wasLost = lost;
              }
              final series = [
                (l.aglLabel, 'agl', 'm'),
                (l.varioLabel, 'vario', 'm/s'),
                (l.towAngle, 'angle', '°'),
                (l.towRope, 'rope', 'm')
              ];
              return ListView(padding: const EdgeInsets.all(20), children: [
                Text('@${rows.first['pilot'] ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge),
                Text(ended ? l.towEnded : l.towActive),
                Text(
                    '${l.towStart}: ${start.toLocal().toString().split('.').first}'),
                Text(
                    '${l.towDuration}: ${duration.inMinutes} min ${duration.inSeconds % 60} s'),
                Text('${l.towMaximum}: ${maxHeight.round()} m'),
                Text('${l.towGaps}: $gaps'),
                for (final s in series) ...[
                  const SizedBox(height: 24),
                  Text('${s.$1} (${s.$3})',
                      style: Theme.of(context).textTheme.titleMedium),
                  _SeriesChart(rows: rows, field: s.$2),
                ],
                const SizedBox(height: 24),
                ExpansionTile(title: Text(l.towSamples), children: [
                  for (final r in rows.reversed.take(300))
                    ListTile(
                        dense: true,
                        title: Text(DateTime.parse(r['time'] as String)
                            .toLocal()
                            .toString()
                            .split('.')
                            .first),
                        subtitle: Text(r['event'] == 'manual_finish'
                            ? l.towEnded
                            : r['lost'] == true
                                ? l.towLost
                                : '${l.aglLabel}: ${_number(r['agl'])} m · ${l.varioLabel}: ${_number(r['vario'])} m/s\n'
                                    '${l.towAngle}: ${_number(r['angle'])}° · ${l.towRope}: ≈ ${_number(r['rope'])} m')),
                ]),
              ]);
            }));
  }

  String _number(Object? value) =>
      value is num ? value.toStringAsFixed(1) : '--';
}

class _SeriesChart extends StatelessWidget {
  const _SeriesChart({required this.rows, required this.field});
  final List<Map<String, dynamic>> rows;
  final String field;
  @override
  Widget build(BuildContext context) {
    final values = rows.map((r) => (r[field] as num?)?.toDouble()).toList();
    final valid = values.whereType<double>();
    if (valid.isEmpty) {
      return const SizedBox(height: 80, child: Center(child: Text('--')));
    }
    final low = valid.reduce(math.min), high = valid.reduce(math.max);
    final times = rows
        .map((r) => DateTime.parse(r['time'] as String)
            .millisecondsSinceEpoch
            .toDouble())
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${low.toStringAsFixed(1)} — ${high.toStringAsFixed(1)}'),
      SizedBox(
          height: 140,
          width: double.infinity,
          child: CustomPaint(
              painter: _TracePainter(values, times, low, high,
                  Theme.of(context).colorScheme.primary))),
    ]);
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter(this.values, this.times, this.low, this.high, this.color);
  final List<double?> values;
  final List<double> times;
  final double low, high;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    var drawing = false;
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        drawing = false;
        continue;
      }
      final x = (times[i] - times.first) /
          math.max(1, times.last - times.first) *
          size.width;
      final y = size.height -
          8 -
          (value - low) / math.max(1, high - low) * (size.height - 16);
      if (!drawing || (i > 0 && times[i] - times[i - 1] > 3000)) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      drawing = true;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) => true;
}
