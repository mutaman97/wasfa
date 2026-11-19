import 'package:erx/screens/otp_screen.dart';
import 'package:erx/app/app_theme.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/widgets/background_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final TextEditingController _phoneNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colors.backgroundColor,
      body: Stack(
        children: [
          const BackgroundBubbles(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 75),
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Enter your phone number",
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 25,
                    color: ColorPalette.honeyDew,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 60,
                  // Remove the BoxDecoration border from here
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    controller: _phoneNoController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 20,
                      color: ColorPalette.honeyDew,
                    ),
                    decoration: InputDecoration(
                      // 1. Define the border here instead
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      // 2. Define the focused border
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colors.territoryColor,
                          width: 2,
                        ),
                      ),
                      hintText: "5434567890",
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 20,
                        color: ColorPalette.honeyDew.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                        child: Text(
                          "+971",
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            color: colors.territoryColor,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    cursorColor: ColorPalette.honeyDew,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Center(
                child: MaterialButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: ColorPalette.malachiteGreen,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return OtpScreen(phoneNo: _phoneNoController.text);
                        },
                      ),
                    );
                  },
                  child: Text(
                    "Next",
                    style: GoogleFonts.nunito(
                      fontSize: 25,
                      color: ColorPalette.chineseBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 75),
            ],
          ),
        ],
      ),
    );
  }
}
