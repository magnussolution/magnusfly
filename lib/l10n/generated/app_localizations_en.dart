// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get towAngle => 'Estimated angle';

  @override
  String get towRope => 'Estimated line';

  @override
  String get towDistance => 'Horizontal distance';

  @override
  String get towFinish => 'Finish tow';

  @override
  String get towFinishing => 'Finish pending pilot confirmation';

  @override
  String get towEnded => 'Tow finished';

  @override
  String get towLost => 'Pilot data lost';

  @override
  String get towGps => 'GPS unavailable or inaccurate';

  @override
  String get towMute => 'Mute connection alarm';

  @override
  String get towHistory => 'Tow history';

  @override
  String get towEmpty => 'No tows recorded';

  @override
  String get towDuration => 'Duration';

  @override
  String get towMaximum => 'Maximum altitude';

  @override
  String get towGaps => 'Connection losses';

  @override
  String get towLocationTitle => 'Location during towing';

  @override
  String get towLocationBody =>
      'MagnusFly uses your location during the tow to estimate angle and line length. The pilot shares their position with the connected driver, including while another app is open. Tow measurements are recorded until the driver finishes.';

  @override
  String get towContinue => 'Continue';

  @override
  String get towRetry => 'Retry GPS';

  @override
  String get towActive => 'Tow in progress';

  @override
  String get towHistoryError => 'Could not save tow history';

  @override
  String get towConfirmFinish => 'Finish this tow and stop pilot transmission?';

  @override
  String get towConfirm => 'Finish';

  @override
  String get towSamples => 'Recorded measurements';

  @override
  String get towStart => 'Start';

  @override
  String get towLosses => 'Communication';

  @override
  String get towNoGps => 'Continue without GPS';

  @override
  String get towRecovered => 'Connection restored';

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

  @override
  String get millisecondsUnit => 'ms';

  @override
  String get driverScreenTitle => 'Driver';

  @override
  String get driverPilotUsernameLabel => 'Pilot username';

  @override
  String get driverPilotUsernameRequired => 'Enter the Pilot username.';

  @override
  String get driverCreateSession => 'Start connection';

  @override
  String get driverCreatingSession => 'Creating Driver session...';

  @override
  String get driverWaitingForSession => 'Waiting to create session';

  @override
  String get driverWaitingForPilot => 'Waiting for the Pilot to accept';

  @override
  String get driverReceivingTelemetry => 'Receiving Pilot telemetry';

  @override
  String get driverTelemetryDelayed => 'Pilot telemetry is delayed';

  @override
  String get driverConnectionError => 'Driver connection error';

  @override
  String get driverSessionCodeLabel => 'Session code';

  @override
  String get delayLabel => 'Delay';

  @override
  String get driverVarioSoundLabel => 'Vario sound';

  @override
  String get pilotUsernameLabel => 'Username';

  @override
  String get pilotNameLabel => 'Name';

  @override
  String get pilotEmailLabel => 'Email';

  @override
  String get pilotCountryLabel => 'Country';

  @override
  String get pilotProfileRequired =>
      'Fill in username, name, email, country, and password.';

  @override
  String get pilotUsernameRequired => 'Enter your username.';

  @override
  String get pilotLoginRequired => 'Enter username and password.';

  @override
  String get pilotAcceptSession => 'Accept Driver connection';

  @override
  String get pilotAcceptingSession => 'Accepting connection...';

  @override
  String get authTitle => 'Pilot profile';

  @override
  String get authSubtitle =>
      'Register or log in before using MagnusFly. Drivers use your username to request your data.';

  @override
  String get authError => 'Login error';

  @override
  String get registerButton => 'Register';

  @override
  String get loginButton => 'Login';

  @override
  String get logoutButton => 'Logout';

  @override
  String get passwordLabel => 'Password';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyUrl =>
      'https://magnussolution.com/magnusfly/privacy.html';

  @override
  String get privacyPolicySummary =>
      'MagnusFly uses your username, name, email, country, password, and towing session telemetry to provide remote variometer transmission between a Pilot and a Driver. Telemetry may include VARIO, AGL, pressure, relative altitude, timestamps, and connection status. Data is sent to the MagnusFly backend over HTTPS and is used only to operate the app, authenticate users, and deliver pilot data to the driver connected to the session. MagnusFly does not sell personal data and does not use advertising SDKs. Delete your account in the app or at https://magnussolution.com/magnusfly/account-deletion.html.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently delete your profile and associated data';

  @override
  String get deleteAccountWarning =>
      'This action is permanent. Your profile, towing sessions, and associated telemetry will be deleted. Enter your password to confirm.';

  @override
  String get deleteAccountButton => 'Delete permanently';

  @override
  String get deleteAccountSuccess =>
      'Your account and associated data have been deleted.';

  @override
  String get deleteAccountError =>
      'Could not delete the account. Check your password and try again.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get closeButton => 'Close';
}
