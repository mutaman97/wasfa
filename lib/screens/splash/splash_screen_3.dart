import 'package:erx/handlers/auth_handler.dart';
import 'package:erx/models/onboard_page_model.dart';
import 'package:erx/screens/onboarding_screen.dart';
import 'package:erx/services/database_service.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen3 extends StatefulWidget {
  const SplashScreen3({Key? key}) : super(key: key);

  @override
  State<SplashScreen3> createState() => _SplashScreen3State();
}

class _SplashScreen3State extends State<SplashScreen3> {
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _prepareAndNavigate();
  }

  Future<void> _prepareAndNavigate() async {
    // After the splash timer, if DB still not ready, show a spinner
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && DatabaseService.isInitialized == false) {
        setState(() => _showLoading = true);
      }
    });

    // Wait for both the splash timer AND database initialization.
    // Whichever takes longer determines when we navigate.
    await Future.wait([
      DatabaseService.initialize(),
      Future.delayed(const Duration(milliseconds: 1100)),
    ]);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FirebaseAuth.instance.currentUser == null
            ? OnBoardingScreen(
                pages: [
                  OnBoardPageModel(
                    image: "assets/lottie/doctor_pad.json",
                    isLottie: true,
                    title: "Get started with standard way of managing your prescription.",
                  ),
                  OnBoardPageModel(
                    image: "assets/lottie/phone_contactless.json",
                    isLottie: true,
                    title: "Contactless and Convenient way of Managing all your Prescriptions at one place.",
                  ),
                  OnBoardPageModel(
                    image: "assets/lottie/plant_hand.json",
                    isLottie: true,
                    title: "Who doesn't love trees?! Go digital and take another step towards saving the planet.",
                  ),
                ],
                onComplete: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AuthHandler()),
                  );
                },
              )
            : AuthHandler(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.chineseBlack,
      body: Stack(
        children: [
          // 1. Logo + hero text — stays centered
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 14),
                        Hero(
                          tag: "e",
                          child: Transform.rotate(
                            angle: 8 * 22 / 7 / 180,
                            child: SvgPicture.string(
                              SvgStrings.logoE,
                              height: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Hero(
                      tag: "pres",
                      child: Visibility(
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            "wasfa",
                            style: GoogleFonts.nunito(
                              color: ColorPalette.honeyDew,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Hero(
                  tag: "sub",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      "Sudan's first ever e-prescription app",
                      style: GoogleFonts.nunito(
                        color: ColorPalette.honeyDew,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Loading indicator — pinned to bottom center
          if (_showLoading)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 60, // distance from bottom edge
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorPalette.malachiteGreen,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Setting things up for the first time...\nThis may take a moment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
