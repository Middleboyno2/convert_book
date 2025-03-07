
import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('vi', 'VN')
  ];

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.map((l) => l.languageCode).contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}