import 'package:flutter/material.dart';

import '../api/magnusfly_api_client.dart';
import '../l10n/generated/app_localizations.dart';
import '../pilot/pilot_profile_store.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({
    required this.onAuthenticated,
    MagnusFlyApiClient? apiClient,
    this.profileStore = const PilotProfileStore(),
    super.key,
  }) : apiClient = apiClient ?? MagnusFlyApiClient();

  final ValueChanged<PilotProfile> onAuthenticated;
  final MagnusFlyApiClient apiClient;
  final PilotProfileStore profileStore;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  Object? _error;
  bool _isWorking = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
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
      return;
    }

    await _runAuth(() => widget.apiClient.registerPilot(profile));
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim().toLowerCase();
    if (username.isEmpty) {
      setState(() {
        _error = AppLocalizations.of(context).pilotUsernameRequired;
      });
      return;
    }

    await _runAuth(() => widget.apiClient.loginPilot(username));
  }

  Future<void> _runAuth(Future<PilotProfile> Function() action) async {
    setState(() {
      _isWorking = true;
      _error = null;
    });

    try {
      final profile = await action();
      await widget.profileStore.save(profile);
      if (!mounted) {
        return;
      }

      widget.onAuthenticated(profile);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.authTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(l10n.authSubtitle),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.pilotUsernameLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.pilotNameLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.pilotEmailLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countryController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.pilotCountryLabel,
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(
                '${l10n.authError}: $_error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _isWorking ? null : _register,
              icon: const Icon(Icons.person_add_alt_outlined),
              label: Text(l10n.registerButton),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isWorking ? null : _login,
              icon: const Icon(Icons.login_outlined),
              label: Text(l10n.loginButton),
            ),
          ],
        ),
      ),
    );
  }
}
