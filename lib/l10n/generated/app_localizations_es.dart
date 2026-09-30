// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MagnusFly';

  @override
  String get homeHeadline => 'Variómetro remoto para remolque de parapente';

  @override
  String get homeSubtitle =>
      'El Conductor inicia la conexión. El Piloto solo acepta la transmisión y sigue enviando VARIO y AGL mientras usa el teléfono en vuelo.';

  @override
  String get startDriver => 'Iniciar como Conductor';

  @override
  String get acceptPilot => 'Aceptar como Piloto';

  @override
  String get settingsTooltip => 'Configuración';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get portuguese => 'Portugués';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get roleRuleTitle => 'Regla de conexión';

  @override
  String get roleRuleBody =>
      'Quien inicia la conexión es el Conductor. Quien acepta la transmisión es el Piloto.';

  @override
  String get pilotPhoneNote =>
      'El Piloto puede mantener XCTrack, Flyskyhy u otra app de vuelo abierta durante el remolque.';

  @override
  String get pilotScreenTitle => 'Transmisión del Piloto';

  @override
  String get pilotTransmissionStarting => 'Iniciando transmisión del Piloto...';

  @override
  String get pilotTransmissionActive => 'Transmisión del Piloto activa';

  @override
  String get pilotTransmissionStopped => 'Transmisión del Piloto detenida';

  @override
  String get pilotTransmissionError => 'Error en la transmisión del Piloto';

  @override
  String get pilotBarometerUnavailable =>
      'Este dispositivo no expone datos de barómetro.';

  @override
  String get stopPilotTransmission => 'Detener transmisión';

  @override
  String get varioLabel => 'VARIO';

  @override
  String get aglLabel => 'AGL';

  @override
  String get pressureLabel => 'Presión';

  @override
  String get relativeAltitudeLabel => 'Altitud relativa';

  @override
  String get metersPerSecondUnit => 'm/s';

  @override
  String get metersUnit => 'm';

  @override
  String get hectopascalUnit => 'hPa';

  @override
  String get millisecondsUnit => 'ms';

  @override
  String get driverScreenTitle => 'Conductor';

  @override
  String get driverPilotUsernameLabel => 'Username del Piloto';

  @override
  String get driverPilotUsernameRequired => 'Informe el username del Piloto.';

  @override
  String get driverCreateSession => 'Iniciar conexión';

  @override
  String get driverCreatingSession => 'Creando sesión del Conductor...';

  @override
  String get driverWaitingForSession => 'Esperando crear sesión';

  @override
  String get driverWaitingForPilot => 'Esperando que el Piloto acepte';

  @override
  String get driverReceivingTelemetry => 'Recibiendo telemetría del Piloto';

  @override
  String get driverTelemetryDelayed =>
      'La telemetría del Piloto está retrasada';

  @override
  String get driverConnectionError => 'Error de conexión del Conductor';

  @override
  String get driverSessionCodeLabel => 'Código de sesión';

  @override
  String get delayLabel => 'Atraso';

  @override
  String get pilotUsernameLabel => 'Username';

  @override
  String get pilotNameLabel => 'Nombre';

  @override
  String get pilotEmailLabel => 'Email';

  @override
  String get pilotCountryLabel => 'País';

  @override
  String get pilotProfileRequired =>
      'Complete username, nombre, email, país y contraseña.';

  @override
  String get pilotUsernameRequired => 'Informe su username.';

  @override
  String get pilotLoginRequired => 'Informe username y contraseña.';

  @override
  String get pilotAcceptSession => 'Aceptar conexión del Conductor';

  @override
  String get pilotAcceptingSession => 'Aceptando conexión...';

  @override
  String get authTitle => 'Perfil del Piloto';

  @override
  String get authSubtitle =>
      'Regístrese o inicie sesión antes de usar MagnusFly. Los Conductores usan su username para solicitar sus datos.';

  @override
  String get authError => 'Error de login';

  @override
  String get registerButton => 'Registrar';

  @override
  String get loginButton => 'Login';

  @override
  String get logoutButton => 'Logout';

  @override
  String get passwordLabel => 'Contraseña';
}
