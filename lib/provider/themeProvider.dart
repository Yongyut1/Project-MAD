import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue; // สีหลักเริ่มต้น
  Color _backgroundColor = Colors.white; // พื้นหลังเริ่มต้น

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Color get backgroundColor => _backgroundColor;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    updateThemeColors();
    notifyListeners();
    await saveTheme(isDarkMode);
  }

  Future<void> saveTheme(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    int colorValue = prefs.getInt('primaryColor') ?? Colors.blue.value;
    _primaryColor = Color(colorValue);

    updateThemeColors();
    notifyListeners();
  }

  Future<void> updatePrimaryColor(Color newColor) async {
    _primaryColor = newColor;
    updateThemeColors();
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', newColor.value);
  }

  void updateThemeColors() {
    _backgroundColor = _themeMode == ThemeMode.dark
        ? _primaryColor.withOpacity(0.2) // ใช้โทนสีหลักใน Dark Mode
        : _primaryColor.withOpacity(0.1); // ใช้โทนสีหลักใน Light Mode
  }
}
