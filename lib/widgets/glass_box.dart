import 'dart:ui';

import 'package:erx/utils/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erx/app/app_theme.dart';

class GlassBox extends StatelessWidget {
  final String text;
  final String svgString;
  const GlassBox({Key? key, required this.text, required this.svgString})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 140,
        height: 70,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.territoryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: colors.backgroundColor.withValues(alpha: 0.3),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 140,
              height: 70,
              color: colors.backgroundColor.withValues(alpha: 0.7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.string(
                    svgString,
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      colors.textDefaultColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: GoogleFonts.notoKufiArabic(
                      color: colors.textDefaultColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
