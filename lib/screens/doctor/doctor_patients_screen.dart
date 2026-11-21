import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/app/app_localization.dart';
import 'package:erx/app/app_theme.dart';
import 'package:erx/screens/doctor/doctor_home_screen.dart';
import 'package:erx/screens/doctor/doctor_profile_screen.dart';
import 'package:erx/screens/drug/drug_interactions_screen.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/widgets/doctor_bottom_nav_bar.dart';
import 'package:erx/widgets/drawers/doctor_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final _searchController = TextEditingController();

    // Stream to get all patients (You can adjust the query if you only want patients this doctor has seen)
    final _patientStream = FirebaseFirestore.instance
        .collection("patient")
        .snapshots();

    return Scaffold(
      backgroundColor: colors.secondaryColor,
      drawer: const DoctorDrawer(),
      body: Stack(
        children: [
          // Background SVG
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
                      // GestureDetector(
                      //   onTap: () => Navigator.pop(context),
                      //   child: Icon(
                      //     Icons.arrow_back_ios_new_rounded,
                      //     color: colors.textDefaultColor,
                      //     size: 24,
                      //   ),
                      // ),
                      // // Title
                      // const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          "Patients",
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      // Three Dots Menu
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: colors.textDefaultColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color:
                            colors.primaryColor, // Matches your main card color
                        onSelected: (value) {
                          if (value == 'edit') {
                            // TODO: Navigate to Edit Profile Screen
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                          } else if (value == 'change_phone') {
                            // TODO: Handle change phone flow
                          } else if (value == 'delete') {
                            // TODO: Handle account deletion with a confirmation dialog
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'Export Patients Data',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.ios_share_outlined,
                                    color: colors.territoryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Export Data',
                                    style: GoogleFonts.notoKufiArabic(
                                      color: colors.textDefaultColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- BODY ---
                Expanded(
                  child: Stack(
                    children: [
                      // Main Content Area
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
                            child:
                                StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>
                                >(
                                  stream: _patientStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final patients = snapshot.data!.docs;

                                      if (patients.isEmpty) {
                                        return Center(
                                          child: Text(
                                            "No patients found.",
                                            style: GoogleFonts.notoKufiArabic(
                                              color: colors.textDefaultColor,
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                        padding: const EdgeInsets.only(
                                          top: 50, // Space for search bar
                                          bottom: 100, // Space for bottom nav
                                          left: 20,
                                          right: 20,
                                        ),
                                        itemCount: patients.length,
                                        itemBuilder: (context, index) {
                                          final doc = patients[index];
                                          final data = doc.data();

                                          return PatientCard(
                                            patientId: doc.id,
                                            name:
                                                (data['name'] as String?) ??
                                                'Unknown Patient',
                                            phoneNo:
                                                (data['phoneNo'] as String?) ??
                                                'No Phone',
                                            age: data['age']?.toString(),
                                            gender: data['gender']?.toString(),
                                          );
                                        },
                                      );
                                    } else {
                                      return Center(
                                        child: SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: CircularProgressIndicator(
                                            color: colors.territoryColor,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                          ),
                        ),
                      ),

                      // --- SEARCH BOX ---
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                  textInputAction: TextInputAction.done,
                                  controller: _searchController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    hintText: "Search patients...",
                                    hintStyle: GoogleFonts.notoKufiArabic(
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
                      ),

                      // --- BOTTOM NAV BAR ---
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: DoctorBottomNavBar(
                          currentIndex: 1, // Highlight Patients tab
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
                              // Already on Patients
                            } else if (index == 2) {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DrugInteractionsScreen(),
                                ),
                              );
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
}

// --- PATIENT CARD WIDGET ---
class PatientCard extends StatelessWidget {
  final String patientId;
  final String name;
  final String phoneNo;
  final String? age;
  final String? gender;

  const PatientCard({
    Key? key,
    required this.patientId,
    required this.name,
    required this.phoneNo,
    this.age,
    this.gender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundColor: colors.primaryColor,
            child: Icon(Icons.person, color: colors.territoryColor, size: 30),
          ),
          const SizedBox(width: 15),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.notoKufiArabic(
                    color: colors.textDefaultColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNo,
                  style: GoogleFonts.nunito(
                    color: colors.textLightColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Age & Gender Badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (age != null && age != "null")
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.territoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$age yrs",
                    style: GoogleFonts.nunito(
                      color: colors.territoryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              if (gender != null && gender != "null")
                Text(
                  gender!,
                  style: GoogleFonts.nunito(
                    color: colors.textLightColor,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
