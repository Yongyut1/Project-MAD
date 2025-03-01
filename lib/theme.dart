import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData lightTheme(Color primaryColor, Color backgroundColor) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Prompt',
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: Colors.teal,
        background: Colors.white, // ✅ เปลี่ยนเป็นสีขาว
        surface: Colors.grey[100]!,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: Colors.white, // ✅ ใช้สีขาวสะอาด
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[200], // ✅ ทำให้ช่องกรอกโดดเด่น
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }


    static ThemeData darkTheme(Color primaryColor, Color backgroundColor) {
      return ThemeData(
        useMaterial3: true,
        fontFamily: 'Prompt',
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: Colors.tealAccent,
          background: backgroundColor,
          surface: Colors.grey[900]!,
          error: Colors.redAccent,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: CardTheme(
          color: backgroundColor.withOpacity(0.3),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800], // ✅ ใช้สีเทาเข้มใน Dark Mode
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          hintStyle: TextStyle(color: Colors.white70), // ✅ ให้ Placeholder เป็นสีขาวซีด
          labelStyle: TextStyle(color: Colors.white), // ✅ ทำให้ Label มองเห็นชัดเจน
        ),
      );
    }

}
