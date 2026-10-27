import 'package:erx/screens/splash_screen_1.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wait for Firebase to fully initialize before doing anything else
  await Firebase.initializeApp();

  // transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: ColorPalette.malachiteGreen,
          primary: ColorPalette.malachiteGreen,
        ),
      ),
      title: "Wasfa",
      debugShowCheckedModeBanner: false,
      // home: FutureBuilder(
      //   future: _initialization,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //       return SplashScreen1(
      //         key: UniqueKey(),
      //         playAnimation: true,
      //       );
      //     } else {
      //       return SplashScreen1(
      //         key: UniqueKey(),
      //         playAnimation: false,
      //       );
      //     }
      //   },
      // ),
      // 4. Remove FutureBuilder since Firebase is already guaranteed to be initialized
      home: SplashScreen1(
        key: UniqueKey(),
        playAnimation: true,
      ),
    );
  }
}
