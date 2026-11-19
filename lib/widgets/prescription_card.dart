import 'dart:ui';

import 'package:erx/app/app_theme.dart';
import 'package:erx/screens/prescription_screen.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

const double _borderRadius = 16;

class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({
    Key? key,
    required this.hospitalName,
    this.doctorName,
    required this.patientName,
    required this.prescriptionDate,
    this.followUpDate,
    required this.prescriptionId,
    // Add the rest of the fields here so they can be passed from Firestore
    this.hospitalAddress,
    this.patientAge,
    this.patientTemp,
    this.patientWeight,
    this.patientBp,
    this.patientHeight,
    this.knownHistory,
    this.diagnosis,
  }) : super(key: key);
  final String hospitalName;
  final String prescriptionId;
  final String? doctorName;
  final String patientName;
  final String prescriptionDate;
  final String? followUpDate;

  // New fields
  final String? hospitalAddress;
  final int? patientAge;
  final int? patientTemp;
  final int? patientWeight;
  final String? patientBp;
  final String? patientHeight;
  final String? knownHistory;
  final String? diagnosis;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PrescriptionScreen(
                prescriptionId: prescriptionId,
                doctorName: doctorName ?? 'Unknown Doctor',
                hospitalName: hospitalName,
                patientName: patientName,
                hospitalAddress: hospitalAddress ?? 'No address provided',
                prescriptionDate: prescriptionDate,
                diagnosis: diagnosis,
                knownHistory: knownHistory,
                patientAge: patientAge,
                patientBp: patientBp,
                patientHeight: patientHeight,
                patientTemp: patientTemp,
                patientWeight: patientWeight,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.15,
                ), // Adjust opacity as needed
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6), // Shadow goes down
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(_borderRadius),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                children: [
                  SvgPicture.string(
                    SvgStrings.presCardBubbles,
                    height: 115,
                    fit: BoxFit.fitHeight,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: colors.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                  Container(
                    color: colors.secondaryColor.withValues(alpha: 0.8),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Hospital name
                            Expanded(
                              child: Text(
                                hospitalName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.notoKufiArabic(
                                  color: colors.textDefaultColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Spacing
                            // Prescription Date
                            Row(
                              children: [
                                SvgPicture.string(
                                  SvgStrings.calendar,
                                  colorFilter: ColorFilter.mode(
                                    colors.textDefaultColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  prescriptionDate,
                                  style: GoogleFonts.notoKufiArabic(
                                    color: colors.textDefaultColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Doctor's name
                        Expanded(
                          child: Text(
                            doctorName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoKufiArabic(
                              color: colors.textDefaultColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // patient name
                            Expanded(
                              child: Text(
                                patientName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.notoKufiArabic(
                                  color: colors.textDefaultColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Spacing
                            // Followup Date
                            Row(
                              children: [
                                SvgPicture.string(SvgStrings.followUp),
                                const SizedBox(width: 5),
                                Text(
                                  followUpDate ?? '',
                                  style: GoogleFonts.notoKufiArabic(
                                    color: colors.territoryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
