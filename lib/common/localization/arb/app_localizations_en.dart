// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TrustTunnel VPN';

  @override
  String get servers => 'Servers';

  @override
  String get routing => 'Routing';

  @override
  String get settings => 'Settings';

  @override
  String get addServer => 'Add VPN server';

  @override
  String get importConfig => 'Import config';

  @override
  String get importConfigFromFile => 'Import from file';

  @override
  String get importConfigFromLink => 'Import from link';

  @override
  String get importConfigLinkHint => 'Paste tt:// link';

  @override
  String get importConfigInvalidFormat => 'Config format is invalid. Please use a valid .toml or tt:// link.';

  @override
  String get importConfigFailed => 'Couldn\'t import config. Please try again.';

  @override
  String get add => 'Add';

  @override
  String get editServer => 'Edit server';

  @override
  String get serverName => 'Server nickname';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get protocol => 'Protocol';

  @override
  String get routingProfile => 'Routing profile';

  @override
  String get enterDnsServerLabel => 'DNS servers (one per line)';

  @override
  String get enterDnsServerHint => 'Example: 1.1.1.1';

  @override
  String get enterIpAddressLabel => 'Server IP address';

  @override
  String get enterIpAddressHint => 'Example: 77.238.253.107';

  @override
  String get enterDomainLabel => 'Secure domain (TLS certificate)';

  @override
  String get enterDomainHint => 'Example: vds.bronos.ru';

  @override
  String get defaultProfile => 'Default profile';

  @override
  String get serversEmptyTitle => 'Set up VPN in 1 minute';

  @override
  String get serversEmptyDescription => 'Tap \"Create server\" and fill in address + login from your admin panel.';

  @override
  String get create => 'Create server';

  @override
  String get save => 'Save changes';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get nameAlreadyExistError => 'This name is already used';

  @override
  String get ipAddressWrongFieldError => 'Use the format x.x.x.x or x:x:x:x:x:x:x:x';

  @override
  String get domainWrongFieldError => 'Use a domain name or IP address';

  @override
  String get dnsServersWrongFieldError => 'Use IP addresses, tls://, https://, quic://, or h3://';

  @override
  String get urlWrongFieldError => 'Please check the URL: it looks incorrect';

  @override
  String get pleaseFillField => 'Please fill out this field';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String get deleteProfileDialogTitle => 'Delete profile?';

  @override
  String get addProfile => 'Add profile';

  @override
  String get enterRulesHint => 'Routing rules can be of the following types:\n- Domains of any level\n- IP address\n- IP address with port\n- IP address with a mask';

  @override
  String get changeDefaultRoutingMode => 'Change default routing';

  @override
  String get deleteAllRules => 'Delete all rules';

  @override
  String get deleteAllRulesDialogTitle => 'Delete all rules?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String deleteAllRulesDialogDescription(String profileName) {
    return 'All rules from $profileName will be deleted';
  }

  @override
  String deleteProfileDescription(String profileName) {
    return '$profileName will be deleted';
  }

  @override
  String get changeDefaultRoutingModeDialogDescription => 'All traffic will be routed by default according to this rule';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get discardChangesDialogTitle => 'Discard changes?';

  @override
  String get discardChangesDialogDescription => 'Are you sure you want to discard all changes?';

  @override
  String get about => 'About';

  @override
  String get queryLog => 'Query log';

  @override
  String get excludedRoutes => 'Excluded routes';

  @override
  String get followUsOnGithub => 'Follow us on Github';

  @override
  String get typeSomething => 'Type something';

  @override
  String get deleteServer => 'Delete server';

  @override
  String get deleteServerDialogTitle => 'Delete server?';

  @override
  String deleteServerDescription(String serverName) {
    return 'Server <b>$serverName</b> will be deleted';
  }

  @override
  String serverDeletedSnackbar(String serverName) {
    return 'Server <b>$serverName</b> deleted';
  }

  @override
  String profileDeletedSnackbar(String profileName) {
    return 'Profile <b>$profileName</b> deleted';
  }

  @override
  String get changesSavedSnackbar => 'Changes saved';

  @override
  String serverCreatedSnackbar(String serverName) {
    return 'Server <b>$serverName</b> created';
  }

  @override
  String serverImportedSnackbar(String serverName) {
    return 'Server \"$serverName\" imported';
  }

  @override
  String profileCreatedSnackbar(String profileName) {
    return 'Profile <b>$profileName</b> created';
  }

  @override
  String get allRulesDeleted => 'All rules deleted';

  @override
  String get importConfigFromClipboard => 'Import from clipboard';

  @override
  String get importConfigClipboardEmpty => 'Clipboard is empty or has no valid link';

  @override
  String get addServerManually => 'Enter manually';

  @override
  String get quic => 'QUIC';

  @override
  String get http2 => 'HTTP/2';

  @override
  String get bypass => 'Bypass';

  @override
  String get vpn => 'Vpn';
}
