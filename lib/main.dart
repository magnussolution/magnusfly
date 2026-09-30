import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api/magnusfly_api_client.dart';
import 'auth/auth_screen.dart';
import 'driver/driver_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'pilot/pilot_screen.dart';
import 'pilot/pilot_profile_store.dart';

void main() {
  runApp(const MagnusFlyApp());
}

class MagnusFlyApp extends StatefulWidget {
  const MagnusFlyApp({super.key});

  @override
  State<MagnusFlyApp> createState() => _MagnusFlyAppState();
}

class _MagnusFlyAppState extends State<MagnusFlyApp> {
  final PilotProfileStore _profileStore = const PilotProfileStore();
  Locale? _locale;
  PilotProfile? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileStore.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _profile = profile;
      _isLoadingProfile = false;
    });
  }

  void _setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _setProfile(PilotProfile profile) {
    setState(() {
      _profile = profile;
    });
  }

  Future<void> _logout() async {
    await _profileStore.clear();
    if (!mounted) {
      return;
    }

    setState(() {
      _profile = null;
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
      home: _isLoadingProfile
          ? const _LoadingScreen()
          : _profile == null
              ? AuthScreen(onAuthenticated: _setProfile)
              : HomeScreen(
                  profile: _profile!,
                  selectedLocale: _locale,
                  onLocaleChanged: _setLocale,
                  onLogout: _logout,
                ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
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
    required this.profile,
    required this.selectedLocale,
    required this.onLocaleChanged,
    required this.onLogout,
    super.key,
  });

  final PilotProfile profile;
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('@${profile.username}'),
            ),
          ),
          IconButton(
            tooltip: l10n.logoutButton,
            icon: const Icon(Icons.logout_outlined),
            onPressed: onLogout,
          ),
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => DriverScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.directions_car_outlined),
              label: Text(l10n.startDriver),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => PilotScreen(profile: profile),
                  ),
                );
              },
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
