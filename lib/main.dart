import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/language_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final languageProvider = LanguageProvider();
  await languageProvider.load();
  runApp(KaiseApp(languageProvider: languageProvider));
}

class KaiseApp extends StatelessWidget {
  final LanguageProvider languageProvider;

  const KaiseApp({super.key, required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: languageProvider,
      child: Consumer<LanguageProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Kaise',
            debugShowCheckedModeBanner: false,
            locale: provider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              primaryColor: Colors.black,
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,
                secondary: Colors.amber,
                surface: Color(0xFF1E1E1E),
              ),
              textTheme: GoogleFonts.outfitTextTheme(
                ThemeData.dark().textTheme.apply(
                      bodyColor: Colors.white,
                      displayColor: Colors.white,
                    ),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
