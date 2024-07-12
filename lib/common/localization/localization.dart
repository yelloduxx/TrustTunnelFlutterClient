import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vpn/common/localization/generated/l10n.dart';
import 'package:vpn/common/localization/locale_type.dart';

final class Localization {
  const Localization._();

  /// Такой подход необходим в связи с тем
  /// что приложение не должно предусматривать смену языка устройства
  /// во время его работы, лишь при перезапуске.
  static Locale? _deviceLocale;

  static const _delegate = AppLocalizations.delegate;

  /// List of supported locales.
  static List<Locale> get supportedLocales => _delegate.supportedLocales;

  static List<Locale> get applicationLocales => List.of([
        defaultLocale,
        ...supportedLocales,
      ]);

  /// List of localization delegates.
  static List<LocalizationsDelegate<void>> get localizationDelegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        _delegate,
      ];

  /// Context-free translations.
  static AppLocalizations get ln => AppLocalizations.current;

  static Locale get deviceLocale => _deviceLocale ??= WidgetsBinding.instance.platformDispatcher.locale;

  /// Computes the default locale.
  ///
  /// This is the locale that is used when no locale is specified.
  static Locale get defaultLocale {
    if (isDeviceLocaleSupported) return deviceLocale;

    return LocaleType.en.value!;
  }

  static Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  /// Obtain [AppLocalizations] instance from [BuildContext].
  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context);

  static bool get isDeviceLocaleSupported => _delegate.isSupported(deviceLocale);
}

extension LocalizationContext on BuildContext {
  AppLocalizations get ln => Localization.of(this);
}
