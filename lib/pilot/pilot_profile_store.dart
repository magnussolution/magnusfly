import 'package:shared_preferences/shared_preferences.dart';

import '../api/magnusfly_api_client.dart';

class PilotProfileStore {
  const PilotProfileStore();

  static const _usernameKey = 'pilot_profile.username';
  static const _nameKey = 'pilot_profile.name';
  static const _emailKey = 'pilot_profile.email';
  static const _countryKey = 'pilot_profile.country';

  Future<PilotProfile?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final username = preferences.getString(_usernameKey);
    final name = preferences.getString(_nameKey);
    final email = preferences.getString(_emailKey);
    final country = preferences.getString(_countryKey);

    if (username == null || name == null || email == null || country == null) {
      return null;
    }

    return PilotProfile(
      username: username,
      name: name,
      email: email,
      country: country,
    );
  }

  Future<void> save(PilotProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_usernameKey, profile.username);
    await preferences.setString(_nameKey, profile.name);
    await preferences.setString(_emailKey, profile.email);
    await preferences.setString(_countryKey, profile.country);
  }
}
