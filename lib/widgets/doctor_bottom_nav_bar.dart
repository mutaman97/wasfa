import 'package:erx/app/app_theme.dart';
import 'package:erx/screens/doctor/doctor_profile_screen.dart'; // Adjust paths as needed
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DoctorBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textDefaultColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.home_rounded,
            label: "Home",
            colors: colors,
          ),

          // 2. Patients
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.people_outline,
            label: "Patients",
            colors: colors,
          ),

          // 3. EMPTY SPACE FOR THE FLOATING ACTION BUTTON (only on Home)
          if (currentIndex == 0) const Expanded(child: SizedBox()),

          // 4. Drug Interaction
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.medication_outlined,
            label: "Interactions",
            colors: colors,
          ),

          // 5. Profile
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.person_outline_rounded,
            label: "Profile",
            colors: colors,
          ),
        ],
      ),
    );
  }

  // Helper widget to build each item
  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required ColorScheme colors,
  }) {
    final bool isActive = currentIndex == index;
    final Color itemColor = isActive
        ? colors.territoryColor
        : colors.textDefaultColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: itemColor, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.notoKufiArabic(
                fontSize: 12,
                color: itemColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
