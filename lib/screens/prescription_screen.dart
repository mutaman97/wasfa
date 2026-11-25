import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/app/app_theme.dart';
import 'package:erx/screens/doctor/edit_prescription_screen.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/utils/toast.dart';
import 'package:erx/widgets/glass_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({
    Key? key,
    required this.prescriptionId,
    required this.displayId,
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
  final String displayId;
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
  final List<dynamic>? medications;

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  // --- Live data (initialised from widget, refreshed from Firestore) ---
  late String _hospitalName;
  late String _doctorName;
  late String _hospitalAddress;
  late String _prescriptionDate;
  late String _displayId;
  late String _patientName;
  int? _patientAge;
  int? _patientTemp;
  int? _patientWeight;
  String? _patientBp;
  String? _patientHeight;
  String? _knownHistory;
  String? _diagnosis;
  List<dynamic>? _medications;

  @override
  void initState() {
    super.initState();
    _seedFromWidget();
    _fetchLatest();
  }

  void _seedFromWidget() {
    _hospitalName = widget.hospitalName;
    _doctorName = widget.doctorName;
    _hospitalAddress = widget.hospitalAddress;
    _prescriptionDate = widget.prescriptionDate;
    _displayId = widget.displayId;
    _patientName = widget.patientName;
    _patientAge = widget.patientAge;
    _patientTemp = widget.patientTemp;
    _patientWeight = widget.patientWeight;
    _patientBp = widget.patientBp;
    _patientHeight = widget.patientHeight;
    _knownHistory = widget.knownHistory;
    _diagnosis = widget.diagnosis;
    _medications = widget.medications;
  }

  Future<void> _fetchLatest() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('prescription')
          .doc(widget.prescriptionId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final patient = (data['patient'] as Map<String, dynamic>?) ?? {};
      final info = (patient['generalInfo'] as Map<String, dynamic>?) ?? {};

      String dateStr = _prescriptionDate;
      if (data['dateTime'] is Timestamp) {
        final ts = (data['dateTime'] as Timestamp).toDate();
        dateStr =
            '${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')}/${ts.year}';
      }

      if (!mounted) return;
      setState(() {
        _displayId = (data['displayId'] ?? _displayId) as String;
        _hospitalName = (data['hospital'] ?? _hospitalName) as String;
        _doctorName = (data['doctorName'] ?? _doctorName) as String;
        _prescriptionDate = dateStr;
        _patientName = (patient['name'] ?? _patientName) as String;
        _patientAge = int.tryParse('${patient['age'] ?? ''}') ?? _patientAge;
        _patientTemp =
            int.tryParse('${info['temperature'] ?? ''}') ?? _patientTemp;
        _patientWeight =
            int.tryParse('${info['weight'] ?? ''}') ?? _patientWeight;
        _patientBp = info['bp'] as String? ?? _patientBp;
        _patientHeight = patient['height'] as String? ?? _patientHeight;
        _knownHistory = data['knownHistory'] as String? ?? _knownHistory;
        _diagnosis = data['diagnosis'] as String? ?? _diagnosis;
        _medications = data['medications'] as List<dynamic>? ?? _medications;
      });
    } catch (_) {
      // Silent — keep showing the values seeded from the widget
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: colors.backgroundColor,

      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: ExpandableFab(
          pos: isRTL ? ExpandableFabPos.left : ExpandableFabPos.right,

          openButtonBuilder: RotateFloatingActionButtonBuilder(
            heroTag: "prescription_fab",
            child: const Icon(Icons.settings_outlined),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.white,
            backgroundColor: colors.territoryColor,
            shape: const CircleBorder(),
          ),

          overlayStyle: ExpandableFabOverlayStyle(
            color: colors.backgroundColor.withOpacity(0.5),
            blur: 5,
          ),

          children: [
            FloatingActionButton.small(
              heroTag: null,
              backgroundColor: colors.secondaryColor,
              foregroundColor: colors.territoryColor,
              onPressed: () {
                // Share logic
              },
              child: const Icon(Icons.share),
            ),
            FloatingActionButton.small(
              heroTag: null,
              backgroundColor: colors.secondaryColor,
              foregroundColor: colors.territoryColor,
              onPressed: () {
                // Print logic
              },
              child: const Icon(Icons.print),
            ),
            FloatingActionButton.small(
              heroTag: null,
              backgroundColor: colors.secondaryColor,
              foregroundColor: colors.territoryColor,
              onPressed: () {
                // Download logic
              },
              child: const Icon(Icons.download),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
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

            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: double.infinity, height: 45),
                    const SizedBox(height: 40),

                    // Hospital details
                    Text(
                      _hospitalName,
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.territoryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Dr. $_doctorName",
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.textDefaultColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _hospitalAddress,
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.textDefaultColor,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // RX ID and Date
                    Row(
                      children: [
                        Text(
                          "RX-",
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _displayId,
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.territoryColor,
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
                          _prescriptionDate,
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Patient Details Section
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
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Name: $_patientName",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoKufiArabic(
                              color: colors.textDefaultColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Age: ${_patientAge ?? '-'} years",
                            textAlign: TextAlign.end,
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

                    // Glass boxes for vitals
                    Center(
                      child: Wrap(
                        runSpacing: 20,
                        spacing: 30,
                        children: [
                          GlassBox(
                            text: _patientTemp == null ? "-" : "$_patientTemp",
                            svgString: SvgStrings.temperature,
                          ),
                          GlassBox(
                            text: _patientWeight == null
                                ? "-"
                                : "$_patientWeight",
                            svgString: SvgStrings.weight,
                          ),
                          GlassBox(
                            text: _patientBp == null ? "-" : "$_patientBp",
                            svgString: SvgStrings.waterDrop,
                          ),
                          GlassBox(
                            text: _patientHeight == null
                                ? "-"
                                : "$_patientHeight",
                            svgString: SvgStrings.height,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Known History
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
                      _knownHistory ?? '-',
                      style: GoogleFonts.notoKufiArabic(
                        color: colors.textDefaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Diagnosis
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
                      _diagnosis ?? '-',
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

            // Three Dots Menu
            Positioned(
              right: 15,
              top: 15,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colors.textDefaultColor,
                  size: 26,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: colors.primaryColor,
                onSelected: (value) async {
                  if (value == 'edit') {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPrescriptionScreen(
                          prescriptionId: widget.prescriptionId,
                        ),
                      ),
                    );

                    if (updated == true && mounted) {
                      await _fetchLatest(); // refresh the visible data
                    }
                  } else if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: colors.backgroundColor,
                        title: Text(
                          'Delete Prescription',
                          style: GoogleFonts.notoKufiArabic(
                            fontWeight: FontWeight.bold,
                            color: colors.textDefaultColor,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete this prescription? '
                          'This action cannot be undone.',
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 14,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.notoKufiArabic(
                                color: colors.textDefaultColor,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: Text(
                              'Delete',
                              style: GoogleFonts.notoKufiArabic(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        await FirebaseFirestore.instance
                            .collection("prescription")
                            .doc(widget.prescriptionId)
                            .delete();

                        if (mounted) {
                          showTextToast("Prescription deleted successfully");
                          Navigator.of(context).pop(true);
                        }
                      } catch (e) {
                        if (mounted) {
                          showTextToast("Error deleting prescription: $e");
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: colors.territoryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: GoogleFonts.notoKufiArabic(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
