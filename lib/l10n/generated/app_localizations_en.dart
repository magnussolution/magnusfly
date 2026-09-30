// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MagnusFly';

  @override
  String get homeHeadline => 'Remote variometer for paraglider towing';

  @override
  String get homeSubtitle =>
      'The Driver starts the connection. The Pilot only accepts transmission and keeps sending VARIO and AGL while using the phone in flight.';

  @override
  String get startDriver => 'Start as Driver';

  @override
  String get acceptPilot => 'Accept as Pilot';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get roleRuleTitle => 'Connection rule';

  @override
  String get roleRuleBody =>
      'Whoever starts the connection is the Driver. Whoever accepts transmission is the Pilot.';

  @override
  String get pilotPhoneNote =>
      'The Pilot may keep XCTrack, Flyskyhy, or another flight app open during towing.';

  @override
  String get pilotScreenTitle => 'Pilot transmission';

  @override
  String get pilotTransmissionStarting => 'Starting Pilot transmission...';

  @override
  String get pilotTransmissionActive => 'Pilot transmission active';

  @override
  String get pilotTransmissionStopped => 'Pilot transmission stopped';

  @override
  String get pilotTransmissionError => 'Pilot transmission error';

  @override
  String get pilotBarometerUnavailable =>
      'This device does not expose barometer data.';

  @override
  String get stopPilotTransmission => 'Stop transmission';

  @override
  String get varioLabel => 'VARIO';

  @override
  String get aglLabel => 'AGL';

  @override
  String get pressureLabel => 'Pressure';

  @override
  String get relativeAltitudeLabel => 'Relative altitude';

  @override
  String get metersPerSecondUnit => 'm/s';

  @override
  String get metersUnit => 'm';

  @override
  String get hectopascalUnit => 'hPa';
}
