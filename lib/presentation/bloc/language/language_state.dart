import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitialState extends LanguageState {}

class LanguageChangedState extends LanguageState {
  final Locale locale;

  const LanguageChangedState({required this.locale});

  @override
  List<Object?> get props => [locale];
}