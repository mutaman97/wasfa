import 'package:erx/app/app_theme.dart';
import 'package:erx/data/cubits/system/app_theme_cubit.dart';
import 'package:erx/providers/locale_provider.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        return Container(
          decoration: const BoxDecoration(
            color: ColorPalette.charlestonGreen,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: ColorPalette.malachiteGreen,
                blurRadius: 10,
                spreadRadius: 0.5,
                offset: Offset(0, -0.5), // Shadow goes UP
              ),
            ],
          ),
          child: SafeArea(
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
                    leading: const Icon(
                      Icons.language,
                      color: ColorPalette.malachiteGreen,
                    ),
                    title: Text(
                      "English",
                      style: GoogleFonts.nunito(color: ColorPalette.honeyDew),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: ColorPalette.coolGrey,
                    ),
                    onTap: () {
                      // 2. Use the captured provider instead of Provider.of(bottomSheetContext)
                      localeProvider.setLocale(const Locale('en'));
                      Navigator.pop(bottomSheetContext); // Close bottom sheet
                    },
                  ),

                  // ARABIC OPTION
                  ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: ColorPalette.malachiteGreen,
                    ),
                    title: Text(
                      "العربية (Arabic)",
                      style: GoogleFonts.nunito(color: ColorPalette.honeyDew),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: ColorPalette.coolGrey,
                    ),
                    onTap: () {
                      // 3. Use the captured provider
                      localeProvider.setLocale(const Locale('ar'));
                      Navigator.pop(bottomSheetContext); // Close bottom sheet
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = context.watch<AppThemeCubit>().isDarkMode();

    return Drawer(
      elevation: 20,
      shadowColor: ColorPalette.malachiteGreen,
      backgroundColor: colors.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  colors.backgroundColor,
                  colors.territoryColor, // Your red accent
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
                    const SizedBox(width: 8),
                    Text(
                      "wasfa",
                      style: GoogleFonts.nunito(
                        color: colors.textColorDark,
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
                    color: colors.textDefaultColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          _buildDrawerItem(
            context: context,
            icon: Icons.home_outlined,
            title: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.history,
            title: 'Prescription History',
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here
            },
          ),

          // --- DARK MODE TOGGLE (Moved Here) ---
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 4,
            ),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: colors.textDefaultColor,
            ),
            title: Text(
              "Dark Mode",
              style: GoogleFonts.nunito(
                color: colors.textDefaultColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            value: isDarkMode,
            activeColor: colors.territoryColor,
            onChanged: (value) {
              context.read<AppThemeCubit>().toggleTheme();
            },
          ),

          // LANGUAGE BUTTON ADDED HERE
          _buildDrawerItem(
            context: context,
            icon: Icons.language,
            title: 'Language',
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              _showLanguageBottomSheet(context); // Open the bottom sheet
            },
          ),

          const Divider(
            color: ColorPalette.charlestonGreen,
            thickness: 1,
            height: 32,
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.redAccent, // Make logout distinct
            iconColor: Colors.redAccent,
            onTap: () {
              Provider.of<SharedPreferences>(
                context,
                listen: false,
              ).remove("userType");
              FirebaseAuth.instance.signOut().then((value) {
                showTextToast("Logout Success!");
              });
            },
          ),
        ],
      ),
    );
  }

  // Helper method to create consistent styled menu items
  Widget _buildDrawerItem({
    required BuildContext context, // <-- Add this
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: iconColor ?? colors.textDefaultColor),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          color: textColor ?? colors.textDefaultColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
