import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _fontKey = 'font_family';
  
  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Roboto';

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Available fonts
  static const List<String> availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Inter',
    'Nunito',
    'Source Sans Pro',
  ];

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeKey) ?? 'light';
    _themeMode = themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _fontFamily = prefs.getString(_fontKey) ?? 'Roboto';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setFontFamily(String fontFamily) async {
    _fontFamily = fontFamily;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, fontFamily);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newThemeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newThemeMode);
  }

  TextTheme _getTextTheme(String fontFamily, Color textColor) {
    switch (fontFamily) {
      case 'Roboto':
        return GoogleFonts.robotoTextTheme().apply(bodyColor: textColor, displayColor: textColor);
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme().apply(bodyColor: textColor, displayColor: textColor);
      case 'Lato':
        return GoogleFonts.latoTextTheme().apply(bodyColor: textColor, displayColor: textColor);
      case 'Montserrat':
        return GoogleFonts.montserratTextTheme().apply(bodyColor: textColor, displayColor: textColor);
      case 'Poppins':
        return GoogleFonts.poppinsTextTheme().apply(bodyColor: textColor, displayColor: textColor);
      case 'Inter':
        return GoogleFonts.interTextTheme().apply(bodyColor: textColor, displayColor: textColor);
      case 'Nunito':
        return GoogleFonts.nunitoTextTheme().apply(bodyColor: textColor, displayColor: textColor);
      case 'Source Sans Pro':
        return GoogleFonts.sourceSans3TextTheme().apply(bodyColor: textColor, displayColor: textColor);
      default:
        return GoogleFonts.robotoTextTheme().apply(bodyColor: textColor, displayColor: textColor);
    }
  }

  // Light theme
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.green,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2E7D32), // Deep botanical green
        secondary: Color(0xFF8BC34A), // Leaf green
        surface: Color(0xFFF5F5F5), // Light gray
        background: Color(0xFFFFFFFF), // White
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF212121), // Dark gray
        onBackground: Color(0xFF212121),
      ),
      textTheme: _getTextTheme(_fontFamily, const Color(0xFF212121)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2E7D32),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Dark theme
  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.green,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50), // Lighter green for dark mode
        secondary: Color(0xFF8BC34A), // Leaf green
        surface: Color(0xFF1E1E1E), // Dark surface
        background: Color(0xFF121212), // Dark background
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Color(0xFFE0E0E0), // Light gray text
        onBackground: Color(0xFFE0E0E0),
      ),
      textTheme: _getTextTheme(_fontFamily, const Color(0xFFE0E0E0)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2E7D32),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}