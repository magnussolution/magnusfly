import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// Application name.
  ///
  /// In en, this message translates to:
  /// **'MagnusFly'**
  String get appTitle;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Remote variometer for paraglider towing'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The Driver starts the connection. The Pilot only accepts transmission and keeps sending VARIO and AGL while using the phone in flight.'**
  String get homeSubtitle;

  /// No description provided for @startDriver.
  ///
  /// In en, this message translates to:
  /// **'Start as Driver'**
  String get startDriver;

  /// No description provided for @acceptPilot.
  ///
  /// In en, this message translates to:
  /// **'Accept as Pilot'**
  String get acceptPilot;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @roleRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection rule'**
  String get roleRuleTitle;

  /// No description provided for @roleRuleBody.
  ///
  /// In en, this message translates to:
  /// **'Whoever starts the connection is the Driver. Whoever accepts transmission is the Pilot.'**
  String get roleRuleBody;

  /// No description provided for @pilotPhoneNote.
  ///
  /// In en, this message translates to:
  /// **'The Pilot may keep XCTrack, Flyskyhy, or another flight app open during towing.'**
  String get pilotPhoneNote;

  /// No description provided for @pilotScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Pilot transmission'**
  String get pilotScreenTitle;

  /// No description provided for @pilotTransmissionStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting Pilot transmission...'**
  String get pilotTransmissionStarting;

  /// No description provided for @pilotTransmissionActive.
  ///
  /// In en, this message translates to:
  /// **'Pilot transmission active'**
  String get pilotTransmissionActive;

  /// No description provided for @pilotTransmissionStopped.
  ///
  /// In en, this message translates to:
  /// **'Pilot transmission stopped'**
  String get pilotTransmissionStopped;

  /// No description provided for @pilotTransmissionError.
  ///
  /// In en, this message translates to:
  /// **'Pilot transmission error'**
  String get pilotTransmissionError;

  /// No description provided for @pilotBarometerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device does not expose barometer data.'**
  String get pilotBarometerUnavailable;

  /// No description provided for @stopPilotTransmission.
  ///
  /// In en, this message translates to:
  /// **'Stop transmission'**
  String get stopPilotTransmission;

  /// No description provided for @varioLabel.
  ///
  /// In en, this message translates to:
  /// **'VARIO'**
  String get varioLabel;

  /// No description provided for @aglLabel.
  ///
  /// In en, this message translates to:
  /// **'AGL'**
  String get aglLabel;

  /// No description provided for @pressureLabel.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressureLabel;

  /// No description provided for @relativeAltitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Relative altitude'**
  String get relativeAltitudeLabel;

  /// No description provided for @metersPerSecondUnit.
  ///
  /// In en, this message translates to:
  /// **'m/s'**
  String get metersPerSecondUnit;

  /// No description provided for @metersUnit.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get metersUnit;

  /// No description provided for @hectopascalUnit.
  ///
  /// In en, this message translates to:
  /// **'hPa'**
  String get hectopascalUnit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
