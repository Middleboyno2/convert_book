import 'package:doantotnghiep/presentation/bloc/language/language_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/language/language_event.dart';
import 'package:doantotnghiep/presentation/bloc/language/language_state.dart';
import 'package:doantotnghiep/presentation/pages/home.dart';
import 'package:doantotnghiep/presentation/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc()..add(LanguageStartedEvent()),
        ),
        // Các bloc provider khác
      ],


      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
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
                themeMode: ThemeMode.system,
                routerConfig: router,

                locale: state is LanguageChangedState ? state.locale : const Locale('en', 'US'),
                localizationsDelegates: [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizationsDelegate.supportedLocales,

              );
            },
            child: const HomePage(),
          );
          return MaterialApp(
            title: 'Multi Language App',

            // Cấu hình localization
            locale: state is LanguageChangedState ? state.locale : const Locale('en', 'US'),
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizationsDelegate.supportedLocales,

            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}


