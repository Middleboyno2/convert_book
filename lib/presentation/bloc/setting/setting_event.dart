import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class LanguageStartedEvent extends SettingEvent {}

class ChangeLanguageEvent extends SettingEvent {
  final String languageCode;

  const ChangeLanguageEvent({required this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}

class ThemeStartedEvent extends SettingEvent {}

class ThemeChangedEvent extends SettingEvent {
  final bool isDarkMode;

  const ThemeChangedEvent({required this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];
}