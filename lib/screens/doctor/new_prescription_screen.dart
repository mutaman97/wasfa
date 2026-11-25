import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:erx/app/app_theme.dart';

class NewPrescriptionScreen extends StatefulWidget {
  const NewPrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<NewPrescriptionScreen> createState() => _NewPrescriptionScreenState();
}

class _NewPrescriptionScreenState extends State<NewPrescriptionScreen> {
  final Color primaryGreen = const Color(0xFF00C853);
  final Color lightBackground = const Color(0xFFF5F7FA);
  final Color cardBackground = Colors.white;

  bool _isLoading = false;

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

  @override
  void initState() {
    super.initState();
    _addDrugRow(); // Start with one empty drug row
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

  void _addDrugRow() {
    setState(() {
      drugRows.add({
        'name': TextEditingController(),
        'dosage': TextEditingController(),
      });
    });
  }

  void _removeDrugRow(int index) {
    setState(() {
      for (var controller in drugRows[index].values) {
        controller.dispose();
      }
      drugRows.removeAt(index);
    });
  }

  // --- FIRESTORE SAVE LOGIC ---
  Future<void> _savePrescription() async {
    if (_patientNameController.text.isEmpty ||
        _hospitalNameController.text.isEmpty) {
      showTextToast("Please fill in Hospital Name and Patient Name");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String docID = FirebaseAuth.instance.currentUser!.phoneNumber!;

      // Fetch doctor's name from your 'doctor' collection
      final doctorDoc = await FirebaseFirestore.instance
          .collection("doctor")
          .doc(docID)
          .get();

      final String docName = doctorDoc.exists
          ? (doctorDoc.data()!["name"] as String? ?? "Unknown Doctor")
          : "Unknown Doctor";

      // Format the medications list
      List<Map<String, String>> medications = drugRows
          .map((row) {
            return {"name": row['name']!.text, "dosage": row['dosage']!.text};
          })
          .where((element) => element['name']!.isNotEmpty)
          .toList();

      // Calculate follow-up date string
      String followUpText = "None";
      if (_followUpDaysController.text.isNotEmpty) {
        int days = int.tryParse(_followUpDaysController.text) ?? 0;
        DateTime followUpDate = DateTime.now().add(Duration(days: days));
        followUpText = DateFormat('yyyy-MM-dd').format(followUpDate);
      }

      // Save to Firestore
      // 1. Create the document reference first (generates a unique ID locally)
      final docRef = FirebaseFirestore.instance
          .collection("prescription")
          .doc();

      // 2. Generate the displayId from the first 8 characters
      final String displayId = docRef.id.substring(0, 8).toUpperCase();

      // 3. Use .set() instead of .add()
      await docRef.set({
        "displayId": displayId, // <-- The human-readable ID
        "doctorID": docID,
        "doctorName": docName,
        "hospital": _hospitalNameController.text,
        "dateTime": FieldValue.serverTimestamp(),
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
      });

      showTextToast("Prescription added successfully");
      Navigator.of(context).pop();
    } catch (e) {
      showTextToast("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
          "Write Digital Prescription",
          style: GoogleFonts.notoKufiArabic(
            fontWeight: FontWeight.bold,
            color: colors.textDefaultColor,
          ),
        ),
      ),
      // 1. Wrap the body in a Stack
      body: Stack(
        children: [
          // 2. The main scrolling content
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 100, // Add extra padding at the bottom so the FAB doesn't cover text
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

          // 3. The Floating Circular Button
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: FloatingActionButton(
                heroTag: "prescription_fab",
                onPressed: _isLoading
                    ? null
                    : _savePrescription, // Use the function from earlier
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
      // 4. Removed bottomNavigationBar entirely
    );
  }

  // --- HELPER WIDGETS ---

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
