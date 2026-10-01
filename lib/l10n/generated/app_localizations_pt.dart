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
  String get driverVarioSoundLabel => 'Som do vario';

  @override
  String get pilotUsernameLabel => 'Username';

  @override
  String get pilotNameLabel => 'Nome';

  @override
  String get pilotEmailLabel => 'Email';

  @override
  String get pilotCountryLabel => 'País';

  @override
  String get pilotProfileRequired =>
      'Preencha username, nome, email, país e senha.';

  @override
  String get pilotUsernameRequired => 'Informe seu username.';

  @override
  String get pilotLoginRequired => 'Informe username e senha.';

  @override
  String get pilotAcceptSession => 'Aceitar conexão do Motorista';

  @override
  String get pilotAcceptingSession => 'Aceitando conexão...';

  @override
  String get authTitle => 'Cadastro do Piloto';

  @override
  String get authSubtitle =>
      'Cadastre-se ou faça login antes de usar o MagnusFly. Motoristas usam seu username para solicitar seus dados.';

  @override
  String get authError => 'Erro de login';

  @override
  String get registerButton => 'Cadastrar';

  @override
  String get loginButton => 'Login';

  @override
  String get logoutButton => 'Logout';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get privacyPolicyTitle => 'Política de privacidade';

  @override
  String get privacyPolicyUrl =>
      'https://magnussolution.com/magnusfly/privacy.html';

  @override
  String get privacyPolicySummary =>
      'O MagnusFly usa seu username, nome, email, país, senha e telemetria da sessão de reboque para oferecer transmissão remota de variômetro entre Piloto e Motorista. A telemetria pode incluir VARIO, AGL, pressão, altitude relativa, horários e estado da conexão. Os dados são enviados ao backend do MagnusFly por HTTPS e usados somente para operar o app, autenticar usuários e entregar os dados do piloto ao motorista conectado à sessão. O MagnusFly não vende dados pessoais e não usa SDKs de publicidade. Você pode excluir a conta no app ou em https://magnussolution.com/magnusfly/account-deletion.html.';

  @override
  String get deleteAccountTitle => 'Excluir conta';

  @override
  String get deleteAccountSubtitle =>
      'Apagar permanentemente seu perfil e dados associados';

  @override
  String get deleteAccountWarning =>
      'Esta ação é permanente. Seu perfil, sessões de reboque e telemetria associada serão excluídos. Informe sua senha para confirmar.';

  @override
  String get deleteAccountButton => 'Excluir permanentemente';

  @override
  String get deleteAccountSuccess =>
      'Sua conta e os dados associados foram excluídos.';

  @override
  String get deleteAccountError =>
      'Não foi possível excluir a conta. Verifique sua senha e tente novamente.';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get closeButton => 'Fechar';
}
