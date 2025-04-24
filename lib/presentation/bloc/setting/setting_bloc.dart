import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/language_constants.dart';
import 'setting_event.dart';
import 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingInitialState()) {
    on<LanguageStartedEvent>(_onStarted);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<ThemeStartedEvent>(_onThemeStarted);
    on<ThemeChangedEvent>(_onThemeChanged);
  }

  Future<void> _onStarted(
      LanguageStartedEvent event,
      Emitter<SettingState> emit,
      ) async {
    // Khi ứng dụng khởi động, lấy ngôn ngữ đã lưu
    final prefs = await SharedPreferences.getInstance();
    // nếu null thì mặc định là English
    final savedLanguageCode = prefs.getString('language_code') ?? 'en';
    final savedCountryCode = prefs.getString('country_code') ?? 'US';

    // nếu null thì = false
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    emit(SettingLoadedState(
      locale: Locale(savedLanguageCode, savedCountryCode),
      isDarkMode: isDarkMode,
    ));
  }

  Future<void> _onChangeLanguage(
      ChangeLanguageEvent event,
      Emitter<SettingState> emit,
      ) async {
    // lấy giá trị isDarkMode từ state
    final currentState = state;
    bool isDarkMode = false;

    if (currentState is SettingLoadedState) {
      isDarkMode = currentState.isDarkMode;
    }

    // Tìm locale từ language code
    final selectedLanguage = LanguageCode.values.firstWhere(
          (lang) => lang.code == event.languageCode,
      orElse: () => LanguageCode.en,
    );

    // Lưu cài đặt ngôn ngữ bằng sharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', selectedLanguage.code);
    await prefs.setString('country_code', selectedLanguage.country);

    // Emit state mới với locale đã chọn
    emit(SettingLoadedState(
      locale: selectedLanguage.locale,
      isDarkMode: isDarkMode,
    ));
  }

  Future<void> _onThemeStarted(
      ThemeStartedEvent event,
      Emitter<SettingState> emit,
      ) async {
    // Get current state to preserve language settings
    final currentState = state;
    Locale locale = const Locale('en', 'US');

    if (currentState is SettingLoadedState) {
      locale = currentState.locale;
    }

    // Khi khởi động, lấy cài đặt theme đã lưu
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    emit(SettingLoadedState(
      locale: locale,
      isDarkMode: isDarkMode,
    ));
  }

  Future<void> _onThemeChanged(
      ThemeChangedEvent event,
      Emitter<SettingState> emit,
      ) async {
    // Get current state to preserve language settings
    final currentState = state;
    Locale locale = const Locale('en', 'US');

    if (currentState is SettingLoadedState) {
      locale = currentState.locale;
    }
    // Lưu cài đặt theme
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', event.isDarkMode);

    // Emit state mới với theme đã chọn
    emit(SettingLoadedState(
      locale: locale,
      isDarkMode: event.isDarkMode,
    ));
  }
}