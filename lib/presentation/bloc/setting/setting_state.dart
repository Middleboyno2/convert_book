import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

class SettingInitialState extends SettingState {}

class SettingLoadedState extends SettingState {
  final Locale locale;
  final bool isDarkMode;

  const SettingLoadedState({
    required this.locale,
    required this.isDarkMode,
  });

  @override
  List<Object?> get props => [locale, isDarkMode];
}