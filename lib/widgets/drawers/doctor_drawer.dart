
import 'package:erx/providers/locale_provider.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class const DoctorDrawer({Key? key}) extends StatelessWidget {
  this : super(key: key);


  void _showLanguageBottomSheet(BuildContext context) {
    // 1. Capture the provider BEFORE opening the bottom sheet
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: ColorPalette.chineseBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Language",
                  style: GoogleFonts.nunito(
                    color: ColorPalette.honeyDew,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // ENGLISH OPTION
                ListTile(
                  leading: const Icon(Icons.language, color: ColorPalette.malachiteGreen),
                  title: Text(
                    "English",
                    style: GoogleFonts.nunito(color: ColorPalette.honeyDew),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: ColorPalette.coolGrey),
                  onTap: () {
                    // 2. Use the captured provider instead of Provider.of(bottomSheetContext)
                    localeProvider.setLocale(const Locale('en'));
                    Navigator.pop(bottomSheetContext); // Close bottom sheet
                  },
                ),
                
                // ARABIC OPTION
                ListTile(
                  leading: const Icon(Icons.language, color: ColorPalette.malachiteGreen),
                  title: Text(
                    "العربية (Arabic)",
                    style: GoogleFonts.nunito(color: ColorPalette.honeyDew),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: ColorPalette.coolGrey),
                  onTap: () {
                    // 3. Use the captured provider
                    localeProvider.setLocale(const Locale('ar'));
                    Navigator.pop(bottomSheetContext); // Close bottom sheet
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 20,
      shadowColor: ColorPalette.malachiteGreen,
      backgroundColor: ColorPalette.chineseBlack,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  ColorPalette.chineseBlack, // Or ColorPalette.chineseBlack if you want it darker
                  ColorPalette.malachiteGreen,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Adding the Logo to match home screen
                Row(
                  children: [
                    // Assuming you have the logo string, if not you can remove this Row
                    // SvgPicture.string(SvgStrings.logoE, height: 24, color: ColorPalette.honeyDew),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Transform.rotate(
                          angle: 8 * 22 / 7 / 180,
                          child: SvgPicture.string(
                            SvgStrings.logoE,
                            height: 38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "wasfa",
                      style: GoogleFonts.nunito(
                        color: ColorPalette.honeyDew,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Doctor Menu",
                  style: GoogleFonts.nunito(
                    color: ColorPalette.coolGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          _buildDrawerItem(
            icon: Icons.home_outlined,
            title: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.history,
            title: 'Prescription History',
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here
            },
          ),

          // LANGUAGE BUTTON ADDED HERE
          _buildDrawerItem(
            icon: Icons.language,
            title: 'Language',
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              _showLanguageBottomSheet(context); // Open the bottom sheet
            },
          ),
          
          const Divider(color: ColorPalette.charlestonGreen, thickness: 1, height: 32),
          
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.redAccent, // Make logout distinct
            iconColor: Colors.redAccent,
            onTap: () {
              // Add logout logic here
            },
          ),
        ],
      ),
    );
  }

  // Helper method to create consistent styled menu items
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = ColorPalette.honeyDew,
    Color iconColor = ColorPalette.honeyDew,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      // Adds a subtle highlight when pressed
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}