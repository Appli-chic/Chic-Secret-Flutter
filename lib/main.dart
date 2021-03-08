import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/ui/screen/landing_screen.dart';
import 'package:chic_secret/utils/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'localization/app_translations_delegate.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chic Secret',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        localizationsDelegates: [
          _newLocaleDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English
          const Locale('fr', ''), // French
        ],
        localeListResolutionCallback: (
            List<Locale>? locales, Iterable<Locale> supportedLocales) {
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
      ),
    );
  }
}
