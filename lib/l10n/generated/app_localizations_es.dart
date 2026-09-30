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
}
