
import 'dart:ui';

enum LanguageCode {
  en('en', 'US', 'English'),
  vi('vi', 'VN', 'Tiếng Việt');

  final String code;
  final String country;
  final String name;

  const LanguageCode(this.code, this.country, this.name);

  Locale get locale => Locale(code, country);
}