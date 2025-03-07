import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/language_constants.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageInitialState()) {
    on<LanguageStartedEvent>(_onStarted);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onStarted(
      LanguageStartedEvent event,
      Emitter<LanguageState> emit,
      ) async {
    // Khi ứng dụng khởi động, lấy ngôn ngữ đã lưu
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('language_code') ?? 'en';
    final savedCountryCode = prefs.getString('country_code') ?? 'US';

    emit(LanguageChangedState(
        locale: Locale(savedLanguageCode, savedCountryCode)
    ));
  }

  Future<void> _onChangeLanguage(
      ChangeLanguageEvent event,
      Emitter<LanguageState> emit,
      ) async {
    // Tìm locale từ language code
    final selectedLanguage = LanguageCode.values.firstWhere(
          (lang) => lang.code == event.languageCode,
      orElse: () => LanguageCode.en,
    );

    // Lưu cài đặt ngôn ngữ
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', selectedLanguage.code);
    await prefs.setString('country_code', selectedLanguage.country);

    // Emit state mới với locale đã chọn
    emit(LanguageChangedState(locale: selectedLanguage.locale));
  }
}