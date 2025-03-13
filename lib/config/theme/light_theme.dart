import 'package:flutter/material.dart';

// const Color color_background = Color(0xFFC8C8CF)
// Light theme configuration for the application
ThemeData lightTheme = ThemeData(
  // Enable Material3 design
  useMaterial3: true,
  // Set the brightness to light
  brightness: Brightness.light,
  // Specify the color scheme seed (primary color)
  // colorSchemeSeed: Colors.black,
  // neu co colorschemeseed thi khong dung colorscheme
  // mau cac widget chinh
  primaryColor: Color(0xFF4B39EF),      // Primary color
  // mau hover/active
  primaryColorLight: Color(0xFF6F61FF),  // Light variant
  primaryColorDark: Color(0xFF2D1FE1),   // Dark variant

  // Màu nền
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  canvasColor: Colors.white,

  // Màu chữ
  textTheme: TextTheme(
    displayLarge: TextStyle(color: Color(0xFF101213), fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: Color(0xFF101213), fontSize: 24, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: Color(0xFF101213), fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(color: Color(0xFF57636C), fontSize: 14, fontWeight: FontWeight.normal),
  ),

  // Màu accent
  colorScheme: ColorScheme.light(
    primary: Color(0xFF4B39EF),
    secondary: Color(0xFF39D2C0),
    tertiary: Color(0xFFEE8B60),
    error: Color(0xFFFF5963),

    // Màu bổ sung
    // background: Color(0xFFF5F5F5),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    // onBackground: Color(0xFF101213),
    onSurface: Color(0xFF101213),
  ),

  // Màu card
  cardColor: Colors.white,
  cardTheme: CardTheme(
    color: Colors.grey.shade300,
    shadowColor: Color(0x33000000),
    elevation: 2,
  ),

  // Màu button
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xffe2ad6d),
    textTheme: ButtonTextTheme.primary,
  ),

  // Màu input
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Color(0xFFF1F4F8),
    focusColor: Color(0xFFFDB55C),
    hintStyle: TextStyle(color: Color(0xFF57636C)),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE0E3E7), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFDB55C), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
  ),

  // Màu appbar
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Color(0xFF404043)),
    titleTextStyle: TextStyle(color: Color(0xFF101213), fontSize: 18, fontWeight: FontWeight.w600),
  ),

  // Màu bottom tab
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF4B39EF),
    unselectedItemColor: Color(0xFF57636C),
  ),

  // mau tabbar
  tabBarTheme: const TabBarTheme(
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: Color(0xffe2ad6d),
        width: 2.0,
      ),
    ),
  ),
);