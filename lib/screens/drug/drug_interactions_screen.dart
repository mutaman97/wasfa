import 'dart:async';

import 'package:erx/app/app_theme.dart';
import 'package:erx/data/cubits/system/drug_interaction/drug_interaction_cubit.dart';
import 'package:erx/screens/doctor/doctor_patients_screen.dart';
import 'package:erx/services/database_service.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/widgets/doctor_bottom_nav_bar.dart';
import 'package:erx/widgets/drawers/doctor_drawer.dart';
import 'package:erx/screens/doctor/doctor_home_screen.dart';
import 'package:erx/screens/doctor/doctor_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DrugInteractionsScreen extends StatefulWidget {
  const DrugInteractionsScreen({Key? key}) : super(key: key);

  @override
  State<DrugInteractionsScreen> createState() => _DrugInteractionsScreenState();
}

class _DrugInteractionsScreenState extends State<DrugInteractionsScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // Autocomplete suggestions from DB
  List<Map<String, String>> _suggestions = [];
  Timer? _debounce;

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce so we don't hit SQLite on every keystroke
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        if (mounted) setState(() => _suggestions = []);
        return;
      }
      final rows = await DatabaseService.database.query(
        'drug_names',
        columns: ['drugbank_id', 'name'],
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        limit: 10,
      );
      if (!mounted) return;
      // Read selected drugs from the Cubit instead of a local variable
      final selected = context.read<DrugInteractionCubit>().state.selected;
      setState(() {
        _suggestions = rows
            .map(
              (r) => {
                'drugbank_id': r['drugbank_id'] as String,
                'name': r['name'] as String,
              },
            )
            .where((r) => !selected.containsKey(r['drugbank_id']))
            .toList();
      });
    });
  }

  void _selectDrug(Map<String, String> drug) {
    context.read<DrugInteractionCubit>().addDrug(
      drug['drugbank_id']!,
      drug['name']!,
    );
    _searchController.clear();
    setState(() => _suggestions = []);
    _focusNode.unfocus();
    _checkInteractions();
  }

  void _removeDrug(String drugbankId) {
    context.read<DrugInteractionCubit>().removeDrug(drugbankId);
    _checkInteractions();
  }

  Future<void> _checkInteractions() async {
    final cubit = context.read<DrugInteractionCubit>();
    final ids = cubit.state.selected.keys.toList();

    if (ids.length < 2) {
      cubit.clearResults();
      return;
    }

    setState(() => _isSearching = true);

    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await DatabaseService.database.rawQuery(
      '''
    SELECT i.drugbank_id, i.target_drugbank_id, i.name AS target_name,
           i.description
    FROM interactions i
    WHERE i.drugbank_id IN ($placeholders)
      AND i.target_drugbank_id IN ($placeholders)
    ''',
      [...ids, ...ids],
    );

    if (!mounted) return;
    setState(() => _isSearching = false);
    cubit.setResults(rows);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DrugInteractionCubit>().state;
    final selectedDrugs = state.selected;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.secondaryColor,
      drawer: const DoctorDrawer(),
      body: Stack(
        children: [
          SvgPicture.string(
            SvgStrings.homeScreenBackground,
            width: MediaQuery.of(context).size.width,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // --- TOP BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Drug Interactions",
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- BODY ---
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(34),
                            topRight: Radius.circular(34),
                          ),
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(34),
                                topRight: Radius.circular(34),
                              ),
                              color: colors.primaryColor,
                            ),
                            child: _buildResultsArea(colors),
                          ),
                        ),
                      ),

                      // --- SEARCH BOX + SUGGESTIONS + CHIPS ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search box + autocomplete — padded
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  height: 60,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: colors.secondaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.territoryColor.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.string(
                                        SvgStrings.search,
                                        colorFilter: ColorFilter.mode(
                                          colors.textLightColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: TextField(
                                          focusNode: _focusNode,
                                          textInputAction: TextInputAction.done,
                                          controller: _searchController,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            enabledBorder: InputBorder.none,
                                            border: InputBorder.none,
                                            hintText: "Search drugs by name...",
                                            hintStyle:
                                                GoogleFonts.notoKufiArabic(
                                                  fontSize: 16,
                                                  color: colors.textLightColor,
                                                ),
                                          ),
                                          style: GoogleFonts.notoKufiArabic(
                                            fontSize: 16,
                                            color: colors.textDefaultColor,
                                          ),
                                          cursorColor: colors.territoryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Autocomplete dropdown
                                if (_suggestions.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    constraints: const BoxConstraints(
                                      maxHeight: 220,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.secondaryColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.territoryColor
                                              .withValues(alpha: 0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: _suggestions.length,
                                      itemBuilder: (context, i) {
                                        final drug = _suggestions[i];
                                        return ListTile(
                                          title: Text(
                                            drug['name']!,
                                            style: GoogleFonts.notoKufiArabic(
                                              color: colors.textDefaultColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          onTap: () => _selectDrug(drug),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Selected chips — single horizontal row, edge-to-edge scroll
                          if (selectedDrugs.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedDrugs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final entry = selectedDrugs.entries.elementAt(
                                    index,
                                  );
                                  return Chip(
                                    label: Text(
                                      entry.value,
                                      style: GoogleFonts.notoKufiArabic(
                                        color: colors.textDefaultColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                    backgroundColor: colors.secondaryColor,
                                    deleteIconColor: colors.territoryColor,
                                    onDeleted: () => _removeDrug(entry.key),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: colors.territoryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),

                      // --- BOTTOM NAV ---
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: DoctorBottomNavBar(
                          currentIndex: 2,
                          onTap: (index) {
                            if (index == 0) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DoctorHomeScreen(),
                                ),
                                (route) => false,
                              );
                            } else if (index == 1) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DoctorPatientsScreen(),
                                ),
                              );
                            } else if (index == 2) {
                              // Already here
                            } else if (index == 3) {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DoctorProfileScreen(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea(ColorScheme colors) {
    final state = context.watch<DrugInteractionCubit>().state;
    final selectedDrugs = state.selected;
    final interactions = state.results;
    final hasSearched = state.hasSearched;

    if (_isSearching) {
      return Center(
        child: SizedBox(
          height: 35,
          width: 35,
          child: CircularProgressIndicator(color: colors.territoryColor),
        ),
      );
    }

    if (!hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Add at least two drugs to check for interactions.",
            textAlign: TextAlign.center,
            style: GoogleFonts.notoKufiArabic(
              color: colors.textLightColor,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (interactions.isEmpty) {
      return Center(
        child: Text(
          "No interactions found.",
          style: GoogleFonts.notoKufiArabic(color: colors.textDefaultColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 100, bottom: 70, left: 20, right: 20),
      itemCount: interactions.length,
      itemBuilder: (context, index) {
        final row = interactions[index];
        final fromId = row['drugbank_id'] as String;
        final toName =
            row['name'] as String? ?? (row['target_name'] as String? ?? '');
        final fromName = selectedDrugs[fromId] ?? fromId;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.secondaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$fromName  ⇄  $toName",
                style: GoogleFonts.notoKufiArabic(
                  color: colors.textDefaultColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                row['description'] as String? ?? '',
                style: GoogleFonts.nunito(
                  color: colors.textLightColor,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
