import 'dart:convert';

import 'package:http/http.dart' as http;
import '../flight/tow_geometry.dart';

class MagnusFlyApiException implements Exception {
  const MagnusFlyApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CreatedSession {
  const CreatedSession({
    required this.code,
    required this.pilotUsername,
    required this.driverToken,
    required this.status,
  });

  final String code;
  final String pilotUsername;
  final String driverToken;
  final String status;
}

class AcceptedSession {
  const AcceptedSession({
    required this.code,
    required this.pilotUsername,
    required this.pilotToken,
    required this.status,
  });

  final String code;
  final String pilotUsername;
  final String pilotToken;
  final String status;
}

class PilotProfile {
  const PilotProfile({
    required this.username,
    required this.name,
    required this.email,
    required this.country,
  });

  final String username;
  final String name;
  final String email;
  final String country;
}

class DriverTelemetrySnapshot {
  const DriverTelemetrySnapshot({
    required this.status,
    required this.lastSeenAgeMs,
    required this.telemetry,
    this.pilotStopped = false,
  });

  final String status;
  final int? lastSeenAgeMs;
  final PilotTelemetry? telemetry;
  final bool pilotStopped;
}

class PilotTelemetry {
  const PilotTelemetry({
    required this.varioMps,
    required this.aglM,
    required this.pressureHpa,
    required this.relativeAltitudeM,
    required this.timestampMillis,
    required this.receivedAgeMs,
    this.id,
    this.location,
  });

  final double varioMps;
  final double aglM;
  final double? pressureHpa;
  final double? relativeAltitudeM;
  final int? timestampMillis;
  final int receivedAgeMs;
  final int? id;
  final Map<String, dynamic>? location;

  TowPosition? positionAt(DateTime now, int totalAgeMs) {
    final fix = location;
    if (fix == null) return null;
    return TowPosition(
        (fix['latitude'] as num).toDouble(),
        (fix['longitude'] as num).toDouble(),
        (fix['accuracy'] as num).toDouble(),
        now.subtract(Duration(
            milliseconds: totalAgeMs + (fix['ageMs'] as num).toInt())));
  }
}

class MagnusFlyApiClient {
  MagnusFlyApiClient({
    http.Client? httpClient,
    Uri? baseUri,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUri =
            baseUri ?? Uri.parse('https://magnussolution.com/magnusfly/api');

  final http.Client _httpClient;
  final Uri _baseUri;

  Future<PilotProfile> registerPilot({
    required PilotProfile profile,
    required String password,
  }) async {
    final json = await _post(_resolve('pilots/register.php'), {
      'username': profile.username,
      'name': profile.name,
      'email': profile.email,
      'country': profile.country,
      'password': password,
    });
    final pilot = json['pilot'] as Map<String, dynamic>;

    return PilotProfile(
      username: pilot['username'] as String,
      name: pilot['name'] as String,
      email: pilot['email'] as String,
      country: pilot['country'] as String,
    );
  }

  Future<PilotProfile> loginPilot({
    required String username,
    required String password,
  }) async {
    final json = await _post(_resolve('pilots/login.php'), {
      'username': username.trim().toLowerCase(),
      'password': password,
    });
    final pilot = json['pilot'] as Map<String, dynamic>;

    return PilotProfile(
      username: pilot['username'] as String,
      name: pilot['name'] as String,
      email: pilot['email'] as String,
      country: pilot['country'] as String,
    );
  }

  Future<void> deletePilot({
    required PilotProfile profile,
    required String password,
  }) async {
    await _post(_resolve('pilots/delete.php'), {
      'username': profile.username,
      'email': profile.email,
      'password': password,
    });
  }

  Future<CreatedSession> createSession({
    required String pilotUsername,
  }) async {
    final json = await _post(_resolve('sessions/create.php'), {
      'pilotUsername': pilotUsername.trim().toLowerCase(),
    });
    final session = json['session'] as Map<String, dynamic>;

    return CreatedSession(
      code: session['code'] as String,
      pilotUsername: session['pilotUsername'] as String,
      driverToken: session['driverToken'] as String,
      status: session['status'] as String,
    );
  }

  Future<AcceptedSession> acceptSession({
    required String pilotUsername,
  }) async {
    final json = await _post(_resolve('sessions/accept.php'), {
      'pilotUsername': pilotUsername.trim().toLowerCase(),
    });
    final session = json['session'] as Map<String, dynamic>;

    return AcceptedSession(
      code: session['code'] as String,
      pilotUsername: session['pilotUsername'] as String,
      pilotToken: session['pilotToken'] as String,
      status: session['status'] as String,
    );
  }

  Future<String> sendPilotTelemetry({
    required String pilotToken,
    required double varioMps,
    required double aglM,
    required double pressureHpa,
    required double relativeAltitudeM,
    required int timestampMillis,
    TowPosition? location,
  }) async {
    final result = await _post(_resolve('telemetry/pilot.php'), {
      'pilotToken': pilotToken,
      'varioMps': varioMps,
      'aglM': aglM,
      'pressureHpa': pressureHpa,
      'relativeAltitudeM': relativeAltitudeM,
      'timestampMillis': timestampMillis,
      'location': location != null && location.usable(DateTime.now())
          ? location.toJson(DateTime.now())
          : null,
    });
    return result['status'] as String? ?? 'active';
  }

  Future<bool> finishSession(String driverToken) async {
    final result = await _post(
        _resolve('sessions/finish.php'), {'driverToken': driverToken});
    return result['pilotStopped'] == true;
  }

  Future<String> pilotStatus(String pilotToken, {bool stopped = false}) async {
    final result = await _post(_resolve('sessions/pilot-status.php'),
        {'pilotToken': pilotToken, 'stopped': stopped});
    return result['status'] as String;
  }

  Future<DriverTelemetrySnapshot> latestTelemetry(String driverToken) async {
    final uri = _resolve('telemetry/latest.php').replace(
      queryParameters: {'driverToken': driverToken},
    );
    final response =
        await _httpClient.get(uri).timeout(const Duration(seconds: 5));
    final json = _decodeResponse(response);
    final session = json['session'] as Map<String, dynamic>;
    final telemetry = json['telemetry'] as Map<String, dynamic>?;

    return DriverTelemetrySnapshot(
      status: session['status'] as String,
      pilotStopped: session['pilotStopped'] == true,
      lastSeenAgeMs: session['lastSeenAgeMs'] as int?,
      telemetry: telemetry == null
          ? null
          : PilotTelemetry(
              id: telemetry['id'] as int?,
              location: telemetry['location'] as Map<String, dynamic>?,
              varioMps: (telemetry['varioMps'] as num).toDouble(),
              aglM: (telemetry['aglM'] as num).toDouble(),
              pressureHpa: (telemetry['pressureHpa'] as num?)?.toDouble(),
              relativeAltitudeM:
                  (telemetry['relativeAltitudeM'] as num?)?.toDouble(),
              timestampMillis: telemetry['timestampMillis'] as int?,
              receivedAgeMs: telemetry['receivedAgeMs'] as int,
            ),
    );
  }

  Future<Map<String, dynamic>> _post(Uri uri, Map<String, Object?> body) async {
    final response = await _httpClient
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 5));

    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'] as Map<String, dynamic>?;
      throw MagnusFlyApiException(
        error?['message'] as String? ?? 'Unexpected API error.',
      );
    }

    return decoded;
  }

  Uri _resolve(String path) {
    final base = _baseUri.toString();
    return Uri.parse('${base.endsWith('/') ? base : '$base/'}$path');
  }
}
