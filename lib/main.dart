import 'dart:io';

import 'package:doantotnghiep/presentation/bloc/auth/auth_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/auth/auth_event.dart';
import 'package:doantotnghiep/presentation/bloc/chat_message/chat_message_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/chat_room/chat_room_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/reader/reader_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/setting/setting_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/setting/setting_event.dart';
import 'package:doantotnghiep/presentation/bloc/setting/setting_state.dart';
import 'package:doantotnghiep/presentation/bloc/user_search/user_search_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/dark_theme.dart';
import 'config/theme/light_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use the auto-generated options from firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // if (Firebase.apps.isEmpty) {
  //   FirebaseOptions options;
  //   if (Platform.isAndroid) {
  //     options = const FirebaseOptions(
  //       apiKey: "AIzaSyB5LidRsnkoQO8x6EaMtjXowjUvQk2JR5E",
  //       appId: "1:1096635672067:android:9bc594f828a0dc8f6a1036",
  //       messagingSenderId: "1096635672067",
  //       projectId: "convertbo",
  //       databaseURL: "https://convertbo-default-rtdb.asia-southeast1.firebasedatabase.app",
  //     );
  //   } else if (Platform.isIOS) {
  //     options = const FirebaseOptions(
  //       apiKey: "AIzaSyB5LidRsnkoQO8x6EaMtjXowjUvQk2JR5E",
  //       appId: "1:1096635672067:ios:1ca25e9b1684de6d6a1036",
  //       messagingSenderId: "1096635672067",
  //       projectId: "convertbo",
  //       databaseURL: "https://convertbo-default-rtdb.asia-southeast1.firebasedatabase.app",
  //     );
  //   } else {
  //     throw UnsupportedError('Unsupported platform');
  //   }
  //   await Firebase.initializeApp(options: options);
  // }

  // After initialization, set the database URL explicitly
  FirebaseDatabase.instance.databaseURL = "https://convertbo-default-rtdb.asia-southeast1.firebasedatabase.app";

  // Khởi tạo dependency injection
  await di.init();
  // App Check với debug provider (dùng khi dev)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingBloc>(
          create: (context) => di.sl<SettingBloc>()
            ..add(LanguageStartedEvent())
            ..add(ThemeStartedEvent()),
          //create: (context) => LoginBloc()..add(LoginStartedEvent())
        ),
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
          lazy: false,
        ),
        BlocProvider<DocumentBloc>(
          create: (_) => di.sl<DocumentBloc>(),
        ),
        BlocProvider<DocumentReaderBloc>(
          create: (_) => di.sl<DocumentReaderBloc>(),
        ),
        BlocProvider<ChatRoomsBloc>(
          create: (_) => di.sl<ChatRoomsBloc>(),
        ),
        BlocProvider<ChatMessagesBloc>(
          create: (_) => di.sl<ChatMessagesBloc>(),
        ),
        BlocProvider<UserSearchBloc>(
          create: (_) => di.sl<UserSearchBloc>(),
        ),
      ],

      child: BlocBuilder<SettingBloc, SettingState>(
        builder: (context, state) {
          final isDark = state is SettingLoadedState?
          state.isDarkMode
              :
          false;
          // get size Screen default
          Size screenSize = MediaQuery.of(context).size;
          return ScreenUtilInit(
            // size screen
            designSize: screenSize,
            // auto text resize
            minTextAdapt: true,
            builder: (context, child){
              return MaterialApp.router(
                // turn off banner debug
                debugShowCheckedModeBanner: false,
                // //title
                // title: AppText.kAppName,
                // Set default theme
                theme: lightTheme,
                // Set the dark theme for dark mode
                darkTheme: darkTheme,
                // Use system theme mode
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                routerConfig: router,

                // setup setting
                locale: state is SettingLoadedState ? state.locale : const Locale('en', 'US'),
                localizationsDelegates: [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizationsDelegate.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }
}


