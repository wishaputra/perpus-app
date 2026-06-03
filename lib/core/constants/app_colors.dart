import 'package:flutter/material.dart';

class AppColors {
  // Theme Light (Dominan Putih-Hitam)
  static const Color bgLight = Color(0xFFF6F6F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF000000); // Tombol hitam pekat
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF6E6E73);
  static const Color borderLight = Color(0xFFE5E5EA);

  // Theme Dark (Dominan Hitam-Putih)
  static const Color bgDark = Color(0xFF0A0A0C);
  static const Color surfaceDark = Color(0xFF16161A);
  static const Color primaryDark = Color(0xFFFFFFFF); // Tombol putih bersih
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8EA8);
  static const Color borderDark = Color(0xFF2C2C2E);

  // Pastel Accent Colors (Inspired by reference mockup)
  static const Color greenPastelBg = Color(0xFFE2F1E8);
  static const Color greenPastelText = Color(0xFF1B4332);
  
  static const Color purplePastelBg = Color(0xFFE8E0FF);
  static const Color purplePastelText = Color(0xFF3F37C9);
  
  static const Color orangePastelBg = Color(0xFFFFF0D4);
  static const Color orangePastelText = Color(0xFF9E5700);

  static const Color bluePastelBg = Color(0xFFE0F7FA);
  static const Color bluePastelText = Color(0xFF006064);

  // Semantic Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);

  // Helper getters based on dynamic context brightness
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackground(BuildContext context) {
    return isDark(context) ? bgDark : bgLight;
  }

  static Color getSurface(BuildContext context) {
    return isDark(context) ? surfaceDark : surfaceLight;
  }

  static Color getPrimary(BuildContext context) {
    return isDark(context) ? primaryDark : primaryLight;
  }

  static Color getOnPrimary(BuildContext context) {
    return isDark(context) ? Colors.black : Colors.white;
  }

  static Color getTextPrimary(BuildContext context) {
    return isDark(context) ? textPrimaryDark : textPrimaryLight;
  }

  static Color getTextSecondary(BuildContext context) {
    return isDark(context) ? textSecondaryDark : textSecondaryLight;
  }

  static Color getBorder(BuildContext context) {
    return isDark(context) ? borderDark : borderLight;
  }
}
