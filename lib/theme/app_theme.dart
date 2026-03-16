import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5F1E8);
  static const Color backgroundLight = Color(0xFFFAF8F3);
  static const Color gold = Color(0xFFC5944A);
  static const Color goldLight = Color(0xFFD4A574);
  static const Color goldDark = Color(0xFFB8863E);
  static const Color darkButton = Color(0xFF2C2C2C);
  static const Color textDark = Color(0xFF3C3C3C);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E1D8);
  static const Color white = Colors.white;
  static const Color circleOverlay = Color(0xFFF5EFE0);
  static const Color slateBlue = Color(0xFF64748B);
}

class AppStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    fontFamily: 'DMSerifDisplay',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 1.0,
  );

  static ButtonStyle goldButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.gold,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle darkButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.darkButton,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textDark,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    side: const BorderSide(color: AppColors.goldLight),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static InputDecoration inputDecoration({
    required String hintText,
    Widget? suffixIcon,
    String? labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      labelText: labelText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
    );
  }
}
