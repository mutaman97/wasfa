
import 'package:erx/utils/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorDrawer extends StatelessWidget {
  const DoctorDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorPalette.chineseBlack,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          DrawerHeader(
            decoration: const BoxDecoration(
              color: ColorPalette.charlestonGreen, // Matches top of home screen
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