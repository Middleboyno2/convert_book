import 'package:flutter/material.dart';

// Light theme configuration for the application
ThemeData darkTheme = ThemeData(

  brightness: Brightness.dark,
  primaryColor: Color(0xFF4B39EF),      // Primary color
  primaryColorLight: Color(0xFF6F61FF),  // Light variant
  primaryColorDark: Color(0xFF2D1FE1),   // Dark variant

  // Màu nền
  scaffoldBackgroundColor: Color(0xFF1A1A1A),
  canvasColor: Color(0xFF252525),

  // Màu chữ
  textTheme: TextTheme(
    displayLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14, fontWeight: FontWeight.normal),
  ),

  // Màu accent
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF4B39EF),
    secondary: Color(0xFF39D2C0),
    tertiary: Color(0xFFEE8B60),
    error: Color(0xFFFF5963),

    // Màu bổ sung
    // background: Color(0xFF1A1A1A),
    surface: Color(0xFF252525),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    // onBackground: Colors.white,
    onSurface: Colors.white,
  ),

  // Màu card
  cardColor: Color(0xFF252525),
  cardTheme: CardTheme(
    color: Color(0xFF252525),
    shadowColor: Color(0x33000000),
    elevation: 2,
  ),

  // Màu button
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFFE2AD6D),
    textTheme: ButtonTextTheme.primary,
  ),

  // Màu input
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Color(0xFF303030),
    focusColor: Color(0xFFFDB55C),
    hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF404040), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFDB55C), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
  ),

  // Màu appbar
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF252525),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
  ),

  // Màu bottom tab
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF252525),
    selectedItemColor: Color(0xFF4B39EF),
    unselectedItemColor: Color(0xFFBBBBBB),
  ),
);