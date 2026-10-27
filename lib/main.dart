import 'package:erx/app/app_localization.dart';
import 'package:erx/screens/splash_screen_1.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/providers/locale_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wait for Firebase to fully initialize
  await Firebase.initializeApp();

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 3. Wrap MaterialApp with ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            // 4. Dynamically change the locale based on the provider
            locale: localeProvider.locale, 
            
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SD'),
            ],
            
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: ColorPalette.malachiteGreen,
                primary: ColorPalette.malachiteGreen,
              ),
            ),
            title: "Wasfa",
            debugShowCheckedModeBanner: false,
            home: SplashScreen1(
              key: UniqueKey(),
              playAnimation: true,
            ),
          );
        },
      ),
    );
  }
}
