import 'dart:ui';

import 'package:erx/app/app_theme.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/widgets/glass_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({
    Key? key,
    required this.prescriptionId,
    required this.hospitalName,
    required this.doctorName,
    required this.hospitalAddress,
    required this.prescriptionDate,
    required this.patientName,
    this.patientAge,
    this.patientTemp,
    this.patientWeight,
    this.patientBp,
    this.patientHeight,
    this.knownHistory,
    this.diagnosis,
    this.medications,
  }) : super(key: key);
  final String prescriptionId;
  final String hospitalName;
  final String doctorName;
  final String hospitalAddress;
  final String prescriptionDate;
  final String patientName;
  final int? patientAge;
  final int? patientTemp;
  final int? patientWeight;
  final String? patientBp;
  final String? patientHeight;
  final String? knownHistory;
  final String? diagnosis;
  final List<dynamic>? medications; // List of dynamic objects for medicines

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background layers
            Positioned(
              left: -63,
              bottom: 35,
              child: SvgPicture.string(SvgStrings.leftBlob),
            ),
            Positioned(
              right: -34,
              top: 100,
              child: SvgPicture.string(SvgStrings.rightBlob),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: colors.backgroundColor.withValues(alpha: 0.3),
              ),
            ),
            Container(color: colors.backgroundColor.withValues(alpha: 0.7)),
            // Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: double.infinity, height: 25),
                    // logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 5),
                            Transform.rotate(
                              angle: 8 * 22 / 7 / 180,
                              child: SvgPicture.string(
                                SvgStrings.logoE,
                                height: 38,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "wasfa",
                          style: GoogleFonts.nunito(
                            color: colors.textDefaultColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Hospital details
                    Text(
                      hospitalName,
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.territoryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Dr. $doctorName",
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.textDefaultColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hospitalAddress,
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.textDefaultColor,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8.0),
                          child: Text(
                            "Id:",
                            style: GoogleFonts.notoKufiArabic(
                              color: colors.territoryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          prescriptionId,
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8.0),
                          child: Icon(
                            Icons.calendar_month,
                            color: colors.textDefaultColor,
                            size: 20,
                          ),
                        ),
                        Text(
                          prescriptionDate,
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      child: Text(
                        "Patient Details",
                        style: GoogleFonts.notoKufiArabic(
                          color: colors.territoryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Wrap Name in Expanded with a flex value
                        Expanded(
                          flex: 3, // Name gets 3 parts of the available space
                          child: Text(
                            "Name: $patientName",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoKufiArabic(
                              color: colors.textDefaultColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ), // Add a little space between them
                        // Wrap Age in Expanded with a smaller flex value
                        Expanded(
                          flex: 2, // Age gets 2 parts of the available space
                          child: Text(
                            "Age: ${patientAge ?? '-'} years",
                            textAlign: TextAlign.end, // Align age to the end (right in LTR, left in RTL)
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoKufiArabic(
                              color: colors.textDefaultColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        runSpacing: 20,
                        spacing: 30,
                        children: [
                          GlassBox(
                            text: patientTemp == null ? "-" : "$patientTemp",
                            svgString: SvgStrings.temperature,
                          ),
                          GlassBox(
                            text: patientWeight == null
                                ? "-"
                                : "$patientWeight",
                            svgString: SvgStrings.weight,
                          ),
                          GlassBox(
                            text: patientBp == null ? "-" : "$patientBp",
                            svgString: SvgStrings.waterDrop,
                          ),
                          GlassBox(
                            text: patientHeight == null
                                ? "-"
                                : "$patientHeight",
                            svgString: SvgStrings.height,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      child: Text(
                        "Known History",
                        style: GoogleFonts.notoKufiArabic(
                          color: colors.territoryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      knownHistory ?? '-',
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.textDefaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      child: Text(
                        "Diagnosis",
                        style: GoogleFonts.notoKufiArabic(
                          color: colors.territoryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      diagnosis ?? '-',
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.textDefaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Close button
            Positioned(
              left: 15,
              top: 15,
              child: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colors.textDefaultColor,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
