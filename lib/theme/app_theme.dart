import 'package:flutter/material.dart';

class AppColors {
  static const blue = Color(0xFF253B78);
  static const deepBlue = Color(0xFF1F315F);
  static const green = Color(0xFF4FA66A);
  static const lightGreen = Color(0xFF6DBE8A);
  static const turquoise = Color(0xFF39B9C9);
  static const lightTurquoise = Color(0xFFA7E3E8);
  static const beige = Color(0xFFF5F1E7);
  static const sand = Color(0xFFFFF2C7);
  static const orange = Color(0xFFF4A14A);
  static const red = Color(0xFFC62828);
  static const gray = Color(0xFF767676);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      secondary: AppColors.green,
      surface: Colors.white,
      error: AppColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.beige,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1.5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.turquoise, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'Выполнено':
    case 'Гости уехали':
    case 'Машина подана':
      return AppColors.green;
    case 'Водитель подтвердил':
      return AppColors.turquoise;
    case 'Передано водителю':
    case 'В расписании':
      return AppColors.blue;
    case 'Срочное изменение':
    case 'Требует уточнения':
    case 'Нет водителя':
    case 'Нет машины':
      return AppColors.orange;
    case 'Изменено':
      return const Color(0xFFB88A00);
    case 'Отменено':
      return AppColors.gray;
    case 'Проблема':
      return AppColors.red;
    case 'Новая заявка':
      return AppColors.lightTurquoise;
    default:
      return AppColors.gray;
  }
}
