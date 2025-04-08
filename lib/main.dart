import 'package:doantotnghiep/presentation/bloc/auth/auth_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/auth/auth_event.dart';
import 'package:doantotnghiep/presentation/bloc/document/document_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/reader/reader_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/setting/setting_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/setting/setting_event.dart';
import 'package:doantotnghiep/presentation/bloc/setting/setting_state.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
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
  // khoi tao firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
          create: (context) => SettingBloc()
            ..add(LanguageStartedEvent())
            ..add(ThemeStartedEvent()),
          //create: (context) => LoginBloc()..add(LoginStartedEvent())
        ),
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<DocumentBloc>(
          create: (_) => di.sl<DocumentBloc>(),
        ),
        BlocProvider<DocumentReaderBloc>(
          create: (_) => di.sl<DocumentReaderBloc>(),
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


