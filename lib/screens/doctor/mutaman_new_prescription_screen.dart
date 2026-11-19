import 'package:erx/app/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewPrescriptionScreen extends StatefulWidget {
  const NewPrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<NewPrescriptionScreen> createState() => _NewPrescriptionScreenState();
}

class _NewPrescriptionScreenState extends State<NewPrescriptionScreen> {
  // Define the green color since we are moving away from the dark palette
  final Color primaryGreen = const Color(0xFF00C853); // Or use your ColorPalette.malachiteGreen
  final Color lightBackground = const Color(0xFFF5F7FA);
  final Color cardBackground = Colors.white;

  // Form State
  String? selectedPatient;
  String? visitType;
  bool showTreatmentPlan = false;
  
  // Text Controllers
  final _complaintsController = TextEditingController();
  final _historyController = TextEditingController();
  final _findingsController = TextEditingController();
  final _investigationController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _planController = TextEditingController();
  final _notesController = TextEditingController();
  final _adviceController = TextEditingController();
  final _followUpDaysController = TextEditingController();
  final _followUpUnitController = TextEditingController(text: "days");

  // Dynamic Drug Rows
  List<Map<String, TextEditingController>> drugRows = [];

  @override
  void initState() {
    super.initState();
    _addDrugRow();
  }

  @override
  void dispose() {
    _complaintsController.dispose();
    _historyController.dispose();
    _findingsController.dispose();
    _investigationController.dispose();
    _diagnosisController.dispose();
    _planController.dispose();
    _notesController.dispose();
    _adviceController.dispose();
    _followUpDaysController.dispose();
    _followUpUnitController.dispose();
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
        'frequency': TextEditingController(),
        'duration': TextEditingController(),
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

  void _clearForm() {
    setState(() {
      _complaintsController.clear();
      _historyController.clear();
      _findingsController.clear();
      _investigationController.clear();
      _diagnosisController.clear();
      _planController.clear();
      _notesController.clear();
      _adviceController.clear();
      _followUpDaysController.clear();
      for (var row in drugRows) {
        for (var controller in row.values) {
          controller.clear();
        }
      }
    });
  }

  void _scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  final _patientSectionKey = GlobalKey();
  final _clinicalSectionKey = GlobalKey();
  final _drugsSectionKey = GlobalKey();
  final _adviceSectionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground, // Light background
      appBar: AppBar(
        backgroundColor: cardBackground,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          "Write Digital Prescription",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: "Clear Form",
            onPressed: _clearForm,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sticky Jump Buttons
          Container(
            color: cardBackground,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildJumpButton("👤 Patient", _patientSectionKey),
                  _buildJumpButton("🩺 Clinical", _clinicalSectionKey),
                  _buildJumpButton("💊 Medicines", _drugsSectionKey),
                  _buildJumpButton("📝 Advice", _adviceSectionKey),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("Patient Info", _patientSectionKey),
                _buildPatientCard(),
                const SizedBox(height: 20),

                _buildSectionHeader("Clinical Notes", _clinicalSectionKey),
                _buildTextField("Chief Complaints", _complaintsController, "e.g. Fever x 3 days, Dry cough..."),
                _buildTextField("History", _historyController, "e.g. No HTN, Non-diabetic"),
                _buildTextField("Clinical Findings / O/E", _findingsController, "e.g. BP: 120/80, Temp: 101°F"),
                _buildTextField("Investigation / Tests Advised", _investigationController, "e.g. CBC with ESR, Chest X-Ray"),
                _buildTextField("Diagnosis", _diagnosisController, "e.g. Acute URTI", maxLines: 2),
                
                CheckboxListTile(
                  title: Text("Treatment Plan", style: GoogleFonts.nunito(color: Colors.black87)),
                  value: showTreatmentPlan,
                  onChanged: (val) => setState(() => showTreatmentPlan = val!),
                  activeColor: primaryGreen,
                  contentPadding: EdgeInsets.zero,
                ),
                if (showTreatmentPlan)
                  _buildTextField("Treatment Plan Details", _planController, "e.g. Scaling & Polishing, RCT..."),
                  
                _buildTextField("Private Doctor Notes (Not Printed)", _notesController, "Internal remarks..."),
                const SizedBox(height: 24),

                _buildSectionHeader("Medications (Rx)", _drugsSectionKey),
                ...drugRows.asMap().entries.map((entry) => _buildDrugRow(entry.key, entry.value)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addDrugRow,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add Medication", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionHeader("Advice & Follow-up", _adviceSectionKey),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField("Follow-up Days", _followUpDaysController, "7", keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _followUpUnitController.text,
                        dropdownColor: cardBackground,
                        style: GoogleFonts.nunito(color: Colors.black87),
                        decoration: _inputDecoration("Unit"),
                        items: ["days", "weeks", "months"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => _followUpUnitController.text = val!,
                      ),
                    ),
                  ],
                ),
                _buildTextField("General Advice", _adviceController, "e.g. Take rest, drink warm water..."),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
      
      // Sticky Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBackground,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black54,
                  side: const BorderSide(color: Colors.black26),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Prescription Saved (Mock)")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save & Preview"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS (Updated for Light Mode) ---

  Widget _buildSectionHeader(String title, GlobalKey key) {
    return Padding(
      key: key,
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

  Widget _buildJumpButton(String label, GlobalKey key) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: lightBackground,
        label: Text(label, style: GoogleFonts.nunito(color: Colors.black87, fontSize: 12)),
        onPressed: () => _scrollToSection(key),
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPatient,
                  dropdownColor: cardBackground,
                  style: GoogleFonts.nunito(color: Colors.black87),
                  decoration: _inputDecoration("Select Patient *"),
                  items: ["Patient A", "Patient B"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => selectedPatient = val),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.person_add, color: primaryGreen),
                tooltip: "Quick Add",
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  style: GoogleFonts.nunito(color: Colors.black87),
                  decoration: _inputDecoration("Visit Date"),
                  readOnly: true,
                  onTap: () async {
                    await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: visitType,
                  dropdownColor: cardBackground,
                  style: GoogleFonts.nunito(color: Colors.black87),
                  decoration: _inputDecoration("Visit Type"),
                  items: ["New Visit", "Follow-up", "Emergency", "Routine"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => visitType = val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.nunito(color: Colors.black87),
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugRow(int index, Map<String, TextEditingController> row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("Medication #${index + 1}", style: GoogleFonts.nunito(color: primaryGreen, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (drugRows.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
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
          Row(
            children: [
              Expanded(child: TextFormField(controller: row['dosage'], style: GoogleFonts.nunito(color: Colors.black87), decoration: _inputDecoration("Dosage"))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: row['frequency'], style: GoogleFonts.nunito(color: Colors.black87), decoration: _inputDecoration("Freq (BD)"))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: row['duration'], style: GoogleFonts.nunito(color: Colors.black87), decoration: _inputDecoration("Duration"))),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: Colors.black38, fontSize: 13),
      filled: true,
      fillColor: lightBackground, // Light grey fill for inputs
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryGreen, width: 1.5),
      ),
    );
  }
}