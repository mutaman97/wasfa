import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/app/app_theme.dart';
import 'package:erx/screens/doctor/doctor_home_screen.dart';
import 'package:erx/screens/doctor/doctor_patients_screen.dart';
import 'package:erx/screens/drug/drug_interactions_screen.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/utils/toast.dart';
import 'package:erx/widgets/doctor_bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final String? phoneNo = FirebaseAuth.instance.currentUser?.phoneNumber;

    final _profileStream = FirebaseFirestore.instance
        .collection("doctor")
        .doc(phoneNo)
        .snapshots();

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: Stack(
        children: [
          // 1. Background SVG
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SvgPicture.string(
                SvgStrings.homeScreenBackground,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // 2. Foreground Layout
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                // --- TOP BAR (Back Button & Title) ---
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
                      // const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "My Profile",
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
                                    'Edit Profile',
                                    style: GoogleFonts.notoKufiArabic(
                                      color: colors.textDefaultColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'change_phone',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone_android_rounded,
                                    color: colors.territoryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Change Number',
                                    style: GoogleFonts.notoKufiArabic(
                                      color: colors.textDefaultColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
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
                                    'Delete Account',
                                    style: GoogleFonts.notoKufiArabic(
                                      color: Colors.redAccent,
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

                // --- PROFILE HEADER (Floating over background) ---
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _profileStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const SizedBox(
                        height: 150,
                      ); // Placeholder while loading
                    }

                    final data = snapshot.data!.data()!;
                    final name = data['name'] as String? ?? 'Unknown';
                    final specialty =
                        data['specialty'] as String? ?? 'General Practitioner';

                    return Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 20),
                      child: Column(
                        children: [
                          // Profile Avatar
                          Center(
                            child: SizedBox(
                              height: 85,
                              width: 85,
                              child: SvgPicture.string(SvgStrings.profile),
                            ),

                            // child: CircleAvatar(
                            //   radius: 40,
                            //   backgroundColor: colors.secondaryColor,
                            //   child: Icon(
                            //     Icons.person,
                            //     size: 50,
                            //     color: colors.territoryColor,
                            //   ),
                            // ),
                          ),
                          const SizedBox(height: 15),

                          // Doctor Name
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ), // Adds left and right padding
                            child: Text(
                              "Dr. $name",
                              textAlign: TextAlign.center, // Centers the text
                              style: GoogleFonts.notoKufiArabic(
                                color: colors.textDefaultColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Specialty
                          Center(
                            child: Text(
                              specialty,
                              style: GoogleFonts.notoKufiArabic(
                                color: colors.territoryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // --- MAIN CONTENT CARD (Pushed down to overlap) ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(34),
                        topRight: Radius.circular(34),
                      ),
                      child: Container(
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
                              DocumentSnapshot<Map<String, dynamic>>
                            >(
                              stream: _profileStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: colors.territoryColor,
                                    ),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Center(
                                    child: Text(
                                      "Profile not found.",
                                      style: GoogleFonts.notoKufiArabic(
                                        color: colors.textDefaultColor,
                                      ),
                                    ),
                                  );
                                }

                                final data = snapshot.data!.data()!;
                                final qualifications =
                                    data['qualifications'] as String? ??
                                    'Not provided';

                                return SingleChildScrollView(
                                  padding: const EdgeInsets.only(
                                    left: 25,
                                    right: 25,
                                    top: 30, // Adjusted top padding since Avatar moved out
                                    bottom: 40,
                                  ),
                                  child: Column(
                                    children: [
                                      // Info Cards
                                      _buildInfoCard(
                                        context: context,
                                        icon: Icons.phone,
                                        title: "Phone Number",
                                        value: phoneNo ?? "N/A",
                                        colors: colors,
                                      ),
                                      const SizedBox(height: 15),

                                      _buildInfoCard(
                                        context: context,
                                        icon: Icons.school,
                                        title: "Qualifications",
                                        value: qualifications,
                                        colors: colors,
                                      ),
                                      const SizedBox(height: 15),

                                      _buildInfoCard(
                                        context: context,
                                        icon: Icons.badge,
                                        title: "Doctor ID",
                                        value: phoneNo ?? "N/A",
                                        colors: colors,
                                      ),

                                      const SizedBox(height: 50),

                                      // Delete Account Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            // await FirebaseAuth.instance
                                            //     .signOut();
                                            showTextToast(
                                              "You Cannot delete your account!",
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            "Delete Account",
                                            style: GoogleFonts.notoKufiArabic(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: 3, // We are on the Profile screen
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
              (route) => false, // Clear history so back button doesn't go weird
            );
          } else if (index == 1) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DoctorPatientsScreen(),
              ),
              (route) => false, // Clear history so back button doesn't go weird
            );
          } else if (index == 2) {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => const DrugInteractionsScreen(),
              ),
            );
          } else if (index == 3) {
            // Already on Profile, do nothing
          }
        },
      ),
    );
  }

  // Helper widget to build the info cards
  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.territoryColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.territoryColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoKufiArabic(
                    color: colors.textLightColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.notoKufiArabic(
                    color: colors.textDefaultColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
