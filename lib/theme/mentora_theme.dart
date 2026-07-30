import 'package:flutter/material.dart';

class MentoraColors {
  static const navy = Color(0xFF061A3D);
  static const navyLight = Color(0xFF102A5C);
  static const gold = Color(0xFFF5A400);

  static const lightBackground = Color(0xFFF8F9FC);
  static const lightCard = Colors.white;
  static const lightText = navy;

  static const darkBackground = navy;
  static const darkCard = Color(0xFF102A5C);
  static const darkText = Colors.white;
}

class MentoraRadius {
  static const small = 12.0;
  static const medium = 18.0;
  static const large = 24.0;
  static const pill = 50.0;
}

class MentoraTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
    primaryColor: MentoraColors.gold,
    cardColor: Colors.white,
    hintColor: Colors.grey,
    appBarTheme: const AppBarTheme(
      backgroundColor: MentoraColors.lightBackground,
      foregroundColor: MentoraColors.navy,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: MentoraColors.navy,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: MentoraColors.navy),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: MentoraColors.navy,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: MentoraColors.navy,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIconColor: MentoraColors.gold,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MentoraRadius.pill),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MentoraColors.gold,
        foregroundColor: MentoraColors.navy,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MentoraRadius.pill),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: MentoraColors.darkBackground,
    primaryColor: MentoraColors.gold,
    cardColor: MentoraColors.darkCard,
    hintColor: Colors.white38,
    appBarTheme: const AppBarTheme(
      backgroundColor: MentoraColors.darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white10,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIconColor: MentoraColors.gold,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MentoraRadius.pill),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MentoraColors.gold,
        foregroundColor: MentoraColors.navy,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MentoraRadius.pill),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
  );
}

class MentoraShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

class MentoraText {
  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const body = TextStyle(fontSize: 15, color: Colors.white70);

  static const goldBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: MentoraColors.gold,
  );
}
