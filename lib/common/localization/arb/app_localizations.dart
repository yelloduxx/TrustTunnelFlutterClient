import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TrustTunnel VPN'**
  String get appTitle;

  /// No description provided for @servers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get servers;

  /// No description provided for @routing.
  ///
  /// In en, this message translates to:
  /// **'Routing'**
  String get routing;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addServer.
  ///
  /// In en, this message translates to:
  /// **'Add VPN server'**
  String get addServer;

  /// No description provided for @importConfig.
  ///
  /// In en, this message translates to:
  /// **'Import config'**
  String get importConfig;

  /// No description provided for @importConfigFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get importConfigFromFile;

  /// No description provided for @importConfigFromLink.
  ///
  /// In en, this message translates to:
  /// **'Import from link'**
  String get importConfigFromLink;

  /// No description provided for @importConfigLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste tt:// link'**
  String get importConfigLinkHint;

  /// No description provided for @importConfigInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Config format is invalid. Please use a valid .toml or tt:// link.'**
  String get importConfigInvalidFormat;

  /// No description provided for @importConfigFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import config. Please try again.'**
  String get importConfigFailed;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @editServer.
  ///
  /// In en, this message translates to:
  /// **'Edit server'**
  String get editServer;

  /// No description provided for @serverName.
  ///
  /// In en, this message translates to:
  /// **'Server nickname'**
  String get serverName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @routingProfile.
  ///
  /// In en, this message translates to:
  /// **'Routing profile'**
  String get routingProfile;

  /// No description provided for @enterDnsServerLabel.
  ///
  /// In en, this message translates to:
  /// **'DNS servers (one per line)'**
  String get enterDnsServerLabel;

  /// No description provided for @enterDnsServerHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 1.1.1.1'**
  String get enterDnsServerHint;

  /// No description provided for @enterIpAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Server IP address'**
  String get enterIpAddressLabel;

  /// No description provided for @enterIpAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 77.238.253.107'**
  String get enterIpAddressHint;

  /// No description provided for @enterDomainLabel.
  ///
  /// In en, this message translates to:
  /// **'Secure domain (TLS certificate)'**
  String get enterDomainLabel;

  /// No description provided for @enterDomainHint.
  ///
  /// In en, this message translates to:
  /// **'Example: vds.bronos.ru'**
  String get enterDomainHint;

  /// No description provided for @defaultProfile.
  ///
  /// In en, this message translates to:
  /// **'Default profile'**
  String get defaultProfile;

  /// No description provided for @serversEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up VPN in 1 minute'**
  String get serversEmptyTitle;

  /// No description provided for @serversEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Create server\" and fill in address + login from your admin panel.'**
  String get serversEmptyDescription;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create server'**
  String get create;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get save;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get unknownError;

  /// No description provided for @nameAlreadyExistError.
  ///
  /// In en, this message translates to:
  /// **'This name is already used'**
  String get nameAlreadyExistError;

  /// No description provided for @ipAddressWrongFieldError.
  ///
  /// In en, this message translates to:
  /// **'Use the format x.x.x.x or x:x:x:x:x:x:x:x'**
  String get ipAddressWrongFieldError;

  /// No description provided for @domainWrongFieldError.
  ///
  /// In en, this message translates to:
  /// **'Use a domain name or IP address'**
  String get domainWrongFieldError;

  /// No description provided for @dnsServersWrongFieldError.
  ///
  /// In en, this message translates to:
  /// **'Use IP addresses, tls://, https://, quic://, or h3://'**
  String get dnsServersWrongFieldError;

  /// No description provided for @urlWrongFieldError.
  ///
  /// In en, this message translates to:
  /// **'Please check the URL: it looks incorrect'**
  String get urlWrongFieldError;

  /// No description provided for @pleaseFillField.
  ///
  /// In en, this message translates to:
  /// **'Please fill out this field'**
  String get pleaseFillField;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get deleteProfile;

  /// No description provided for @deleteProfileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile?'**
  String get deleteProfileDialogTitle;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get addProfile;

  /// No description provided for @enterRulesHint.
  ///
  /// In en, this message translates to:
  /// **'Routing rules can be of the following types:\n- Domains of any level\n- IP address\n- IP address with port\n- IP address with a mask'**
  String get enterRulesHint;

  /// No description provided for @changeDefaultRoutingMode.
  ///
  /// In en, this message translates to:
  /// **'Change default routing'**
  String get changeDefaultRoutingMode;

  /// No description provided for @deleteAllRules.
  ///
  /// In en, this message translates to:
  /// **'Delete all rules'**
  String get deleteAllRules;

  /// No description provided for @deleteAllRulesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all rules?'**
  String get deleteAllRulesDialogTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAllRulesDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'All rules from {profileName} will be deleted'**
  String deleteAllRulesDialogDescription(String profileName);

  /// No description provided for @deleteProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'{profileName} will be deleted'**
  String deleteProfileDescription(String profileName);

  /// No description provided for @changeDefaultRoutingModeDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'All traffic will be routed by default according to this rule'**
  String get changeDefaultRoutingModeDialogDescription;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discardChanges;

  /// No description provided for @discardChangesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesDialogTitle;

  /// No description provided for @discardChangesDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard all changes?'**
  String get discardChangesDialogDescription;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @queryLog.
  ///
  /// In en, this message translates to:
  /// **'Query log'**
  String get queryLog;

  /// No description provided for @excludedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Excluded routes'**
  String get excludedRoutes;

  /// No description provided for @followUsOnGithub.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Github'**
  String get followUsOnGithub;

  /// No description provided for @typeSomething.
  ///
  /// In en, this message translates to:
  /// **'Type something'**
  String get typeSomething;

  /// No description provided for @deleteServer.
  ///
  /// In en, this message translates to:
  /// **'Delete server'**
  String get deleteServer;

  /// No description provided for @deleteServerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete server?'**
  String get deleteServerDialogTitle;

  /// No description provided for @deleteServerDescription.
  ///
  /// In en, this message translates to:
  /// **'Server <b>{serverName}</b> will be deleted'**
  String deleteServerDescription(String serverName);

  /// No description provided for @serverDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Server <b>{serverName}</b> deleted'**
  String serverDeletedSnackbar(String serverName);

  /// No description provided for @profileDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Profile <b>{profileName}</b> deleted'**
  String profileDeletedSnackbar(String profileName);

  /// No description provided for @changesSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSavedSnackbar;

  /// No description provided for @serverCreatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Server <b>{serverName}</b> created'**
  String serverCreatedSnackbar(String serverName);

  /// No description provided for @serverImportedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Server \"{serverName}\" imported'**
  String serverImportedSnackbar(String serverName);

  /// No description provided for @profileCreatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Profile <b>{profileName}</b> created'**
  String profileCreatedSnackbar(String profileName);

  /// No description provided for @allRulesDeleted.
  ///
  /// In en, this message translates to:
  /// **'All rules deleted'**
  String get allRulesDeleted;

  /// No description provided for @importConfigFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Import from clipboard'**
  String get importConfigFromClipboard;

  /// No description provided for @importConfigClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty or has no valid link'**
  String get importConfigClipboardEmpty;

  /// No description provided for @addServerManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get addServerManually;

  /// No description provided for @quic.
  ///
  /// In en, this message translates to:
  /// **'QUIC'**
  String get quic;

  /// No description provided for @http2.
  ///
  /// In en, this message translates to:
  /// **'HTTP/2'**
  String get http2;

  /// No description provided for @bypass.
  ///
  /// In en, this message translates to:
  /// **'Bypass'**
  String get bypass;

  /// No description provided for @vpn.
  ///
  /// In en, this message translates to:
  /// **'Vpn'**
  String get vpn;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
