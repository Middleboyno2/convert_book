import 'package:doantotnghiep/presentation/bloc/language/language_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/language/language_event.dart';
import 'package:doantotnghiep/presentation/bloc/language/language_state.dart';
import 'package:doantotnghiep/presentation/pages/library.dart';
import 'package:doantotnghiep/presentation/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/dark_theme.dart';
import 'config/theme/light_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';



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
                // setup language
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
            child: SplashScreen(),
          );

        },
      ),
    );
  }
}


