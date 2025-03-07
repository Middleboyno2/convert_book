import 'package:equatable/equatable.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

class LanguageStartedEvent extends LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final String languageCode;

  const ChangeLanguageEvent({required this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}