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
}
