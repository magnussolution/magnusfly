import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';

void main() {
  runApp(const MagnusFlyApp());
}

class MagnusFlyApp extends StatefulWidget {
  const MagnusFlyApp({super.key});

  @override
  State<MagnusFlyApp> createState() => _MagnusFlyAppState();
}

class _MagnusFlyAppState extends State<MagnusFlyApp> {
  Locale? _locale;

  void _setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: _resolveLocale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(
        selectedLocale: _locale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

Locale _resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
  if (locale == null) {
    return const Locale('en');
  }

  for (final supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == locale.languageCode) {
      return supportedLocale;
    }
  }

  return const Locale('en');
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.selectedLocale,
    required this.onLocaleChanged,
    super.key,
  });

  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => SettingsScreen(
                    selectedLocale: selectedLocale,
                    onLocaleChanged: onLocaleChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.homeHeadline,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(l10n.homeSubtitle),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.directions_car_outlined),
              label: Text(l10n.startDriver),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.paragliding_outlined),
              label: Text(l10n.acceptPilot),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.roleRuleTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.roleRuleBody),
            const SizedBox(height: 16),
            Text(l10n.pilotPhoneNote),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.selectedLocale,
    required this.onLocaleChanged,
    super.key,
  });

  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text(l10n.languageTitle),
            ),
            LanguageTile(
              title: l10n.english,
              locale: const Locale('en'),
              selectedLocale: selectedLocale,
              onLocaleChanged: onLocaleChanged,
            ),
            LanguageTile(
              title: l10n.portuguese,
              locale: const Locale('pt'),
              selectedLocale: selectedLocale,
              onLocaleChanged: onLocaleChanged,
            ),
            LanguageTile(
              title: l10n.spanish,
              locale: const Locale('es'),
              selectedLocale: selectedLocale,
              onLocaleChanged: onLocaleChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  const LanguageTile({
    required this.title,
    required this.locale,
    required this.selectedLocale,
    required this.onLocaleChanged,
    super.key,
  });

  final String title;
  final Locale locale;
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedLocale?.languageCode == locale.languageCode;

    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => onLocaleChanged(locale),
    );
  }
}
