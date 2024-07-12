// import 'package:vpn/common/localization/locale_type.dart';
// import 'package:vpn/common/localization/localization.dart';
//
// const _fallbackValue = 'English*';
//
// extension LocaleTypeNativeName on LocaleType {
//   String get toNativeName => switch (this) {
//         LocaleType.system => Localization.isDeviceLocaleSupported
//             ? LocaleType.fromLocale(Localization.deviceLocale)!._toSystemName
//             : _toSystemName,
//         LocaleType.en => 'English',
//         LocaleType.de => 'Deutsch',
//         LocaleType.fr => 'Français',
//         LocaleType.it => 'Italiano',
//         LocaleType.ru => 'Русский',
//         LocaleType.ja => '日本語',
//         LocaleType.zh => '中文',
//         LocaleType.ko => '한국어',
//       };
//
//   String get _toSystemName => switch (this) {
//         LocaleType.ru => 'Системный ($toNativeName)',
//         LocaleType.system => 'System ($_fallbackValue)',
//         _ => 'System ($toNativeName)',
//       };
// }
