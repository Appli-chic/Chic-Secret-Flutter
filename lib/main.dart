import 'dart:async';
import 'dart:io';

import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/screen/landing_screen.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'localization/app_translations_delegate.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  await initDatabase();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late AppTranslationsDelegate _newLocaleDelegate;

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: Locale('en', ''));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SynchronizationProvider(),
        ),
      ],
      child: _createApp(),
    );
  }

  Widget _createApp() {
    if (Platform.isIOS) {
      return _createIosApp();
    } else {
      return _createAndroidApp();
    }
  }

  Widget _createIosApp() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Chic Secret',
        theme: CupertinoThemeData(brightness: Brightness.dark),
        localizationsDelegates: [
          _newLocaleDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English
          const Locale('fr', ''), // French
          const Locale('es', ''), // Spanish
        ],
        localeListResolutionCallback:
            (List<Locale>? locales, Iterable<Locale> supportedLocales) {
          if (locales != null) {
            for (final locale in locales) {
              var localeFiltered = supportedLocales
                  .where((l) => l.languageCode == locale.languageCode);

              if (localeFiltered.isNotEmpty) {
                _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
                return locale;
              }
            }
          }

          return Locale('en', '');
        },
        home: LandingScreen(),
        builder: EasyLoading.init(),
      ),
    );
  }

  Widget _createAndroidApp() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chic Secret',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      localizationsDelegates: [
        _newLocaleDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('fr', ''), // French
        const Locale('es', ''), // Spanish
      ],
      localeListResolutionCallback:
          (List<Locale>? locales, Iterable<Locale> supportedLocales) {
        if (locales != null) {
          for (final locale in locales) {
            var localeFiltered = supportedLocales
                .where((l) => l.languageCode == locale.languageCode);

            if (localeFiltered.isNotEmpty) {
              _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
              return locale;
            }
          }
        }

        return Locale('en', '');
      },
      home: LandingScreen(),
      builder: EasyLoading.init(),
    );
  }
}
