
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<void> load() async {
    // Load JSON file
    String jsonString = await rootBundle.loadString(
        'lib/core/localization/l10n/app_${locale.languageCode}.json'
    );

    // Decode JSON
    _localizedStrings = json.decode(jsonString);
  }

  // Phương thức dịch đa cấp
  String translate(String key) {
    // Hỗ trợ keys lồng nhau như 'auth.username'
    return _getNestedValue(key, _localizedStrings) ?? key;
  }

  // Hỗ trợ interpolation
  String translateWithArgs(String key, {Map<String, String>? args}) {
    String translation = translate(key);

    if (args != null) {
      args.forEach((k, v) {
        translation = translation.replaceAll('{$k}', v);
      });
    }

    return translation;
  }

  // Hàm hỗ trợ lấy giá trị keys lồng nhau
  dynamic _getNestedValue(String key, Map<String, dynamic> map) {
    List<String> keys = key.split('.');
    dynamic value = map;

    for (String k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }

    return value;
  }
}