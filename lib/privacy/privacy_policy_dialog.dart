import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

Future<void> showPrivacyPolicyDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.privacyPolicyTitle),
        content: SingleChildScrollView(
          child: Text(l10n.privacyPolicySummary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.closeButton),
          ),
        ],
      );
    },
  );
}
