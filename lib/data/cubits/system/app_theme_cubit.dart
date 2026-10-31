// lib/data/cubits/system/app_theme_cubit.dart
import 'package:erx/app/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeCubit extends Cubit<AppTheme> {
  AppThemeCubit() : super(AppTheme.dark) {
    _loadTheme();
  }

  // Load the saved theme when the app starts
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    emit(isDark ? AppTheme.dark : AppTheme.light);
  }

  // Toggle between light and dark
  Future<void> toggleTheme() async {
    final toggledTheme = state == AppTheme.light
        ? AppTheme.dark
        : AppTheme.light;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', toggledTheme == AppTheme.dark);

    emit(toggledTheme);
  }

  bool isDarkMode() {
    return state == AppTheme.dark;
  }
}
