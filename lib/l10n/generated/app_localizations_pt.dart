// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MagnusFly';

  @override
  String get homeHeadline => 'Variômetro remoto para reboque de parapente';

  @override
  String get homeSubtitle =>
      'O Motorista inicia a conexão. O Piloto apenas aceita a transmissão e continua enviando VARIO e AGL enquanto usa o celular em voo.';

  @override
  String get startDriver => 'Iniciar como Motorista';

  @override
  String get acceptPilot => 'Aceitar como Piloto';

  @override
  String get settingsTooltip => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get portuguese => 'Português';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get roleRuleTitle => 'Regra da conexão';

  @override
  String get roleRuleBody =>
      'Quem inicia a conexão é o Motorista. Quem aceita a transmissão é o Piloto.';

  @override
  String get pilotPhoneNote =>
      'O Piloto pode manter XCTrack, Flyskyhy ou outro app de voo aberto durante o reboque.';

  @override
  String get pilotScreenTitle => 'Transmissão do Piloto';

  @override
  String get pilotTransmissionStarting => 'Iniciando transmissão do Piloto...';

  @override
  String get pilotTransmissionActive => 'Transmissão do Piloto ativa';

  @override
  String get pilotTransmissionStopped => 'Transmissão do Piloto parada';

  @override
  String get pilotTransmissionError => 'Erro na transmissão do Piloto';

  @override
  String get pilotBarometerUnavailable =>
      'Este dispositivo não expõe dados do barômetro.';

  @override
  String get stopPilotTransmission => 'Parar transmissão';

  @override
  String get varioLabel => 'VARIO';

  @override
  String get aglLabel => 'AGL';

  @override
  String get pressureLabel => 'Pressão';

  @override
  String get relativeAltitudeLabel => 'Altitude relativa';

  @override
  String get metersPerSecondUnit => 'm/s';

  @override
  String get metersUnit => 'm';

  @override
  String get hectopascalUnit => 'hPa';

  @override
  String get millisecondsUnit => 'ms';

  @override
  String get driverScreenTitle => 'Motorista';

  @override
  String get driverPilotUsernameLabel => 'Username do Piloto';

  @override
  String get driverPilotUsernameRequired => 'Informe o username do Piloto.';

  @override
  String get driverCreateSession => 'Iniciar conexão';

  @override
  String get driverCreatingSession => 'Criando sessão do Motorista...';

  @override
  String get driverWaitingForSession => 'Aguardando criação da sessão';

  @override
  String get driverWaitingForPilot => 'Aguardando o Piloto aceitar';

  @override
  String get driverReceivingTelemetry => 'Recebendo telemetria do Piloto';

  @override
  String get driverTelemetryDelayed => 'A telemetria do Piloto está atrasada';

  @override
  String get driverConnectionError => 'Erro na conexão do Motorista';

  @override
  String get driverSessionCodeLabel => 'Código da sessão';

  @override
  String get delayLabel => 'Atraso';

  @override
  String get pilotUsernameLabel => 'Username';

  @override
  String get pilotNameLabel => 'Nome';

  @override
  String get pilotEmailLabel => 'Email';

  @override
  String get pilotCountryLabel => 'País';

  @override
  String get pilotProfileRequired => 'Preencha username, nome, email e país.';

  @override
  String get pilotAcceptSession => 'Aceitar conexão do Motorista';

  @override
  String get pilotAcceptingSession => 'Aceitando conexão...';
}
