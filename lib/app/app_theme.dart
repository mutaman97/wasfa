import 'package:flutter/material.dart';

enum AppTheme { light, dark }

// --- ALL COLORS DEFINED HERE (from your theme.dart) ---

// Light Theme Colors
const Color primaryColor_ = Color(0xFFF6F5FA);
const Color secondaryColor_ = Color(0xFFFFFFFF);
const Color territoryColor_ = Color(0xff5ADD83);
const Color forthColor_ = Color(0xffFA6E53);
const Color _backgroundColor = primaryColor_;
const Color textDarkColor = Color(0xFF000000);
Color lightTextColor = const Color(0xFF000000).withValues(alpha: 0.5);
Color widgetsBorderColorLight = const Color(0xffEEEEEE).withValues(alpha: 0.6);

// Dark Theme Colors
Color primaryColorDark = const Color(0xff111418);
Color secondaryColorDark = const Color(0xff222831);
const Color territoryColorDark = Color(0xff5ADD83);
Color deactivateColorLight = const Color(0xff7F7F7F);
const Color forthColorDark = Color(0xffFA6E53);
Color backgroundColorDark = primaryColorDark;
const Color textColorDarkTheme = Color(0xffFDFDFD);
Color lightTextColorDarkTheme = const Color(0xffFDFDFD).withValues(alpha: 0.3);
Color widgetsBorderColorDark = const Color(0x1aFDFDFD);

// Message & Status Colors
const Color errorMessageColor = Color.fromARGB(255, 166, 4, 4);
const Color successMessageColor = Color(0xff00B2CA);
const Color warningMessageColor = Color(0xFFC2AF6F);

// Helper to get color based on brightness
Color _getColor(
  Brightness brightness, {
  required Color lightColor,
  required Color darkColor,
}) {
  return brightness == Brightness.light ? lightColor : darkColor;
}

// --- EXTENSION FOR DYNAMIC COLORS ---
extension ColorPrefs on ColorScheme {
  Color get primaryColor => _getColor(
    brightness,
    lightColor: primaryColor_,
    darkColor: primaryColorDark,
  );
  Color get secondaryColor => _getColor(
    brightness,
    lightColor: secondaryColor_,
    darkColor: secondaryColorDark,
  );
  Color get secondaryDetailsColor => _getColor(
    brightness,
    lightColor: secondaryColor_,
    darkColor: primaryColorDark,
  );
  Color get territoryColor => _getColor(
    brightness,
    lightColor: territoryColor_,
    darkColor: territoryColorDark,
  );
  Color get deactivateColor => _getColor(
    brightness,
    lightColor: deactivateColorLight,
    darkColor: deactivateColorLight,
  );
  Color get forthColor =>
      _getColor(brightness, lightColor: forthColor_, darkColor: forthColorDark);
  Color get backgroundColor => _getColor(
    brightness,
    lightColor: _backgroundColor,
    darkColor: backgroundColorDark,
  );
  Color get textColorDark => _getColor(
    brightness,
    lightColor: textDarkColor,
    darkColor: textColorDarkTheme,
  );
  Color get textDefaultColor => _getColor(
    brightness,
    lightColor: textDarkColor,
    darkColor: textColorDarkTheme,
  );
  Color get textLightColor => _getColor(
    brightness,
    lightColor: lightTextColor,
    darkColor: lightTextColorDarkTheme,
  );
  Color get borderColor => _getColor(
    brightness,
    lightColor: widgetsBorderColorLight,
    darkColor: secondaryColorDark.withValues(alpha: 0.2),
  );
  Color get inverseThemeColor => _getColor(
    brightness,
    lightColor: secondaryColorDark,
    darkColor: secondaryColor_,
  );
  Color get blackColor => Colors.black;
}

// --- THEME DATA ---
class _CommonThemeProperties {
  static const String fontFamily = "Noto_Kufi_Arabic";
  static const bool useMaterial3 = true;
}

final appThemeData = {
  AppTheme.light: ThemeData(
    brightness: Brightness.light,
    useMaterial3: _CommonThemeProperties.useMaterial3,
    fontFamily: _CommonThemeProperties.fontFamily,

    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: territoryColor_,
      cursorColor: territoryColor_,
      selectionHandleColor: territoryColor_,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(territoryColor_),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return territoryColor_.withValues(alpha: 0.3);
        }
        return primaryColorDark;
      }),
    ),

    colorScheme: ColorScheme.fromSeed(
      error: errorMessageColor,
      seedColor: territoryColor_,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: secondaryColor_,
      foregroundColor: textDarkColor,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  ),

  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    useMaterial3: _CommonThemeProperties.useMaterial3,
    fontFamily: _CommonThemeProperties.fontFamily,

    textSelectionTheme: const TextSelectionThemeData(
      selectionHandleColor: territoryColorDark,
      selectionColor: territoryColorDark,
      cursorColor: territoryColorDark,
    ),

    colorScheme: ColorScheme.fromSeed(
      error: errorMessageColor.withValues(alpha: 0.7),
      seedColor: territoryColorDark,
      brightness: Brightness.dark,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(territoryColor_),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return territoryColor_.withValues(alpha: 0.3);
        }
        return primaryColor_.withValues(alpha: 0.2);
      }),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: secondaryColorDark,
      foregroundColor: textColorDarkTheme,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
};
