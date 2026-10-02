import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'tow_geometry.dart';

class TowLocation {
  StreamSubscription<Position>? _subscription;
  TowPosition? latest;

  Future<bool> prepare() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void start({required bool pilot, required String notification}) {
    LocationSettings settings = const LocationSettings(
        accuracy: LocationAccuracy.best, distanceFilter: 0);
    if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 1),
          foregroundNotificationConfig: pilot
              ? ForegroundNotificationConfig(
                  notificationTitle: 'MagnusFly',
                  notificationText: notification,
                  enableWakeLock: true)
              : null);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      settings = AppleSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: pilot,
          allowBackgroundLocationUpdates: pilot);
    }
    _subscription =
        Geolocator.getPositionStream(locationSettings: settings).listen((p) {
      latest = TowPosition(p.latitude, p.longitude, p.accuracy, p.timestamp);
    }, onError: (Object _) {
      latest = null;
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    latest = null;
  }
}
