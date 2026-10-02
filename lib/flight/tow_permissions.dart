import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'tow_location.dart';

Future<bool> prepareTowLocation(
    BuildContext context, TowLocation location) async {
  final l = AppLocalizations.of(context);
  final consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(l.towLocationTitle),
            content: Text(l.towLocationBody),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.towNoGps)),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l.towContinue))
            ],
          ));
  if (consent != true) return false;
  try {
    return await location.prepare();
  } catch (_) {
    return false;
  }
}
