import 'package:flutter/material.dart';

class AppColors {
  static const blue = Color(0xFF263C68);
  static const deepBlue = Color(0xFF101B33);
  static const midnight = Color(0xFF07101F);
  static const green = Color(0xFF75C98B);
  static const lightGreen = Color(0xFFBDEBC3);
  static const turquoise = Color(0xFF55CFE3);
  static const lightTurquoise = Color(0xFFDDF7FA);
  static const beige = Color(0xFFF6F8FB);
  static const sand = Color(0xFFFFF0C8);
  static const orange = Color(0xFFF4A64F);
  static const sunset = Color(0xFFFF8A4C);
  static const red = Color(0xFFC73838);
  static const gray = Color(0xFF667085);
  static const line = Color(0xFFE4EAF2);
  static const panel = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      secondary: AppColors.turquoise,
      surface: AppColors.panel,
      error: AppColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.beige,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.midnight,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        surfaceTintColor: AppColors.panel,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.turquoise, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.gray, fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.line, width: 1.4),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      ),
    );
  }
}

const appBackgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFF7FAFC),
    Color(0xFFEFF7FB),
    Color(0xFFFFF7E7),
  ],
);

const brandHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.midnight,
    AppColors.blue,
    Color(0xFF178CA3),
  ],
);

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
