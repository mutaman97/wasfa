import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:erx/app/app_theme.dart';

class EditPrescriptionScreen extends StatefulWidget {
  /// The Firestore document ID of the prescription to edit.
  final String prescriptionId;

  /// Optional: pass the already-fetched data to skip the loading spinner.
  final Map<String, dynamic>? initialData;

  const EditPrescriptionScreen({
    Key? key,
    required this.prescriptionId,
    this.initialData,
  }) : super(key: key);

  @override
  State<EditPrescriptionScreen> createState() => _EditPrescriptionScreenState();
}

class _EditPrescriptionScreenState extends State<EditPrescriptionScreen> {
  final Color primaryGreen = const Color(0xFF00C853);
  final Color lightBackground = const Color(0xFFF5F7FA);
  final Color cardBackground = Colors.white;

  bool _isLoading = false;
  bool _isFetching = true;
  String? _loadError;

  // Text Controllers
  final _hospitalNameController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _patientNumberController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();
  final _bpController = TextEditingController();
  final _knownHistoryController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _adviceController = TextEditingController();
  final _followUpDaysController = TextEditingController();

  // Dynamic Drug Rows
  List<Map<String, TextEditingController>> drugRows = [];

  // Store the original follow-up date so we can re-derive days on edit
  DateTime? _originalFollowUpDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _populateFromData(widget.initialData!);
      _isFetching = false;
    } else {
      _fetchPrescription();
    }
  }

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _patientNameController.dispose();
    _patientNumberController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _bpController.dispose();
    _knownHistoryController.dispose();
    _diagnosisController.dispose();
    _adviceController.dispose();
    _followUpDaysController.dispose();
    for (var row in drugRows) {
      for (var controller in row.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  // --- DATA LOADING ---

  Future<void> _fetchPrescription() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("prescription")
          .doc(widget.prescriptionId)
          .get();

      if (!doc.exists) {
        setState(() {
          _loadError = "Prescription not found.";
          _isFetching = false;
        });
        return;
      }

      _populateFromData(doc.data()!);
      setState(() => _isFetching = false);
    } catch (e) {
      setState(() {
        _loadError = "Error loading prescription: $e";
        _isFetching = false;
      });
    }
  }

  /// Fills all controllers from a Firestore document map.
  void _populateFromData(Map<String, dynamic> data) {
    _hospitalNameController.text = (data['hospital'] ?? '') as String;

    // Patient nested map
    final patient = (data['patient'] as Map<String, dynamic>?) ?? {};
    _patientNameController.text = (patient['name'] ?? '') as String;
    _ageController.text = (patient['age'] ?? '') as String;
    _genderController.text = (patient['gender'] ?? '') as String;

    final generalInfo = (patient['generalInfo'] as Map<String, dynamic>?) ?? {};
    _temperatureController.text = (generalInfo['temperature'] ?? '') as String;
    _weightController.text = (generalInfo['weight'] ?? '') as String;
    _bpController.text = (generalInfo['bp'] ?? '') as String;

    // Strip the "971" prefix for editing
    final phone = (data['patientPhone'] ?? '') as String;
    _patientNumberController.text = phone.startsWith('971')
        ? phone.substring(3)
        : phone;

    _knownHistoryController.text = (data['knownHistory'] ?? '') as String;
    _diagnosisController.text = (data['diagnosis'] ?? '') as String;
    _adviceController.text = (data['advice'] ?? '') as String;

    // Follow-up date -> days
    final followUp = (data['followUp'] ?? '') as String;
    if (followUp.isNotEmpty && followUp != 'None') {
      try {
        final parsed = DateFormat('yyyy-MM-dd').parse(followUp);
        _originalFollowUpDate = parsed;
        final diff = parsed.difference(
          DateTime(parsed.year, parsed.month, parsed.day),
        );
        _followUpDaysController.text = diff.inDays >= 0
            ? diff.inDays.toString()
            : '0';
      } catch (_) {
        // Leave blank if parse fails
      }
    }

    // Medications
    final meds = (data['medications'] as List<dynamic>?) ?? [];
    drugRows.clear();
    if (meds.isEmpty) {
      _addDrugRowInternal();
    } else {
      for (final med in meds) {
        final m = med as Map<String, dynamic>;
        drugRows.add({
          'name': TextEditingController(text: (m['name'] ?? '') as String),
          'dosage': TextEditingController(text: (m['dosage'] ?? '') as String),
        });
      }
    }
  }

  void _addDrugRowInternal() {
    drugRows.add({
      'name': TextEditingController(),
      'dosage': TextEditingController(),
    });
  }

  // --- DRUG ROW MANAGEMENT ---

  void _addDrugRow() {
    setState(() => _addDrugRowInternal());
  }

  void _removeDrugRow(int index) {
    setState(() {
      for (var controller in drugRows[index].values) {
        controller.dispose();
      }
      drugRows.removeAt(index);
    });
  }

  // --- FIRESTORE UPDATE LOGIC ---

  Future<void> _updatePrescription() async {
    if (_patientNameController.text.isEmpty ||
        _hospitalNameController.text.isEmpty) {
      showTextToast("Please fill in Hospital Name and Patient Name");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Format the medications list
      List<Map<String, String>> medications = drugRows
          .map((row) {
            return {"name": row['name']!.text, "dosage": row['dosage']!.text};
          })
          .where((element) => element['name']!.isNotEmpty)
          .toList();

      // Recalculate follow-up date from days field
      String followUpText = "None";
      if (_followUpDaysController.text.isNotEmpty) {
        int days = int.tryParse(_followUpDaysController.text) ?? 0;
        DateTime followUpDate = DateTime.now().add(Duration(days: days));
        followUpText = DateFormat('yyyy-MM-dd').format(followUpDate);
      }

      await FirebaseFirestore.instance
          .collection("prescription")
          .doc(widget.prescriptionId)
          .update({
            "hospital": _hospitalNameController.text,
            "patientPhone": "971${_patientNumberController.text}",
            "patient": {
              "name": _patientNameController.text,
              "age": _ageController.text,
              "gender": _genderController.text,
              "generalInfo": {
                "temperature": _temperatureController.text,
                "bp": _bpController.text,
                "weight": _weightController.text,
              },
            },
            "knownHistory": _knownHistoryController.text,
            "diagnosis": _diagnosisController.text,
            "advice": _adviceController.text,
            "medications": medications,
            "followUp": followUpText,
            // Doctor ID/name and displayId are intentionally NOT updated —
            // they belong to the original author and creation.
          });

      showTextToast("Prescription updated successfully");
      Navigator.of(context).pop(true); // return `true` so caller can refresh
    } catch (e) {
      showTextToast("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        elevation: 1,
        iconTheme: IconThemeData(color: colors.textDefaultColor),
        title: Text(
          "Edit Prescription",
          style: GoogleFonts.notoKufiArabic(
            fontWeight: FontWeight.bold,
            color: colors.textDefaultColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_isFetching)
            const Center(child: CircularProgressIndicator())
          else if (_loadError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(color: colors.textDefaultColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isFetching = true;
                          _loadError = null;
                        });
                        _fetchPrescription();
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 100,
              ),
              children: [
                _buildSectionHeader("Hospital & Patient Info"),
                _buildPatientCard(),
                const SizedBox(height: 20),

                _buildSectionHeader("Clinical Notes"),
                _buildTextField(
                  "Known History",
                  _knownHistoryController,
                  "e.g. Diabetes, HTN...",
                ),
                _buildTextField(
                  "Diagnosis",
                  _diagnosisController,
                  "e.g. Acute URTI",
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                _buildSectionHeader("Medications (Rx)"),
                ...drugRows.asMap().entries.map(
                  (entry) => _buildDrugRow(entry.key, entry.value),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addDrugRow,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Add Medication",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionHeader("Advice & Follow-up"),
                _buildTextField(
                  "General Advice",
                  _adviceController,
                  "e.g. Take rest, drink warm water...",
                ),
                _buildTextField(
                  "Follow-up (in Days)",
                  _followUpDaysController,
                  "e.g. 7",
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 50),
              ],
            ),

          // Save FAB — hidden while fetching/erroring
          if (!_isFetching && _loadError == null)
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: FloatingActionButton(
                  heroTag: "edit_prescription_fab",
                  onPressed: _isLoading ? null : _updatePrescription,
                  backgroundColor: colors.territoryColor,
                  shape: const CircleBorder(),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.done, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS (identical to NewPrescriptionScreen) ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryGreen,
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.textDefaultColor.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            "Hospital Name",
            _hospitalNameController,
            "e.g. Royal Care International Hospital",
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Patient Name",
                  _patientNameController,
                  "Full Name",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  "Patient Phone",
                  _patientNumberController,
                  "Exclude 971",
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Age",
                  _ageController,
                  "e.g. 25",
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  "Gender",
                  _genderController,
                  "Male/Female",
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Temp (°C)",
                  _temperatureController,
                  "e.g. 37",
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  "Weight (kg)",
                  _weightController,
                  "e.g. 70",
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField("BP", _bpController, "e.g. 120/80"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.notoKufiArabic(
              color: colors.textDefaultColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.notoKufiArabic(color: colors.textLightColor),
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugRow(int index, Map<String, TextEditingController> row) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.textDefaultColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textDefaultColor.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Medication #${index + 1}",
                style: GoogleFonts.nunito(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (drugRows.length > 1)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => _removeDrugRow(index),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: row['name'],
            style: GoogleFonts.nunito(color: Colors.black87),
            decoration: _inputDecoration("Drug Name (e.g. Panadol 500mg)"),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: row['dosage'],
            style: GoogleFonts.nunito(color: Colors.black87),
            decoration: _inputDecoration(
              "Dosage & Frequency (e.g. 1 tablet twice a day)",
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: colors.textLightColor, fontSize: 13),
      filled: true,
      fillColor: colors.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colors.textDefaultColor.withValues(alpha: 0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.territoryColor, width: 1.5),
      ),
    );
  }
}
