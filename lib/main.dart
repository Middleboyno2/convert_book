import 'package:doantotnghiep/presentation/bloc/language/language_bloc.dart';
import 'package:doantotnghiep/presentation/bloc/language/language_event.dart';
import 'package:doantotnghiep/presentation/bloc/language/language_state.dart';
import 'package:doantotnghiep/presentation/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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


