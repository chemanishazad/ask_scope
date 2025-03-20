import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/palette.dart';
import '../const/styles.dart';

ThemeData lightTheme(double fontSize) {
  return ThemeData(
    primaryColor: Palette.themeColor,
    colorScheme: const ColorScheme.light(
      primary: Palette.themeColor,
      secondary: Palette.themeColor,
      surface: Palette.lightBackgroundColor,
    ),
    scaffoldBackgroundColor: Palette.whiteColor,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Palette.whiteColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSize + 6,
          fontWeight: FontWeight.bold,
          color: Palette.blackColor,
        ),
        displayMedium: TextStyle(
          fontSize: fontSize + 4,
          fontWeight: FontWeight.w600,
          color: Palette.blackColor,
        ),
        displaySmall: TextStyle(
          fontSize: fontSize + 2,
          fontWeight: FontWeight.w500,
          color: Palette.blackColor,
        ),
        headlineLarge: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Palette.blackColor,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w600,
          color: Palette.blackColor,
        ),
        headlineSmall: TextStyle(
          fontSize: fontSize - 4,
          fontWeight: FontWeight.w500,
          color: Palette.blackColor,
        ),
        titleLarge: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w600,
          color: Palette.blackColor,
        ),
        titleMedium: TextStyle(
          fontSize: fontSize - 4,
          fontWeight: FontWeight.w500,
          color: Palette.blackColor,
        ),
        titleSmall: TextStyle(
          fontSize: fontSize - 6,
          fontWeight: FontWeight.w400,
          color: Palette.blackColor,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w400,
          color: Palette.blackColor,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSize - 4,
          fontWeight: FontWeight.w400,
          color: Palette.blackColor,
        ),
        bodySmall: TextStyle(
          fontSize: fontSize - 6,
          fontWeight: FontWeight.w300,
          color: Palette.blackColor,
        ),
        labelLarge: TextStyle(
          fontSize: fontSize - 4,
          fontWeight: FontWeight.w500,
          color: Palette.blackColor,
        ),
        labelMedium: TextStyle(
          fontSize: fontSize - 6,
          fontWeight: FontWeight.w400,
          color: Palette.blackColor,
        ),
        labelSmall: TextStyle(
          fontSize: fontSize - 8,
          fontWeight: FontWeight.w300,
          color: Palette.blackColor,
        ),
      ),
    ),
    iconTheme: IconThemeData(color: Palette.themeColor, size: fontSize),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      fillColor: Palette.lightGreyColor,
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle(
        fontSize: fontSize,
        foregroundColor: Palette.whiteColor,
        backgroundColor: Palette.buttonColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: outlinedButtonStyle(
        fontSize: fontSize,
        foregroundColor: Palette.themeColor,
        borderColor: Palette.buttonColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: textButtonStyle(
        foregroundColor: Palette.buttonColor,
        fontSize: fontSize,
      ),
    ),
  );
}

ThemeData darkTheme(double fontSize) {
  return ThemeData(
    primaryColor: Palette.themeColor,
    colorScheme: const ColorScheme.dark(
      primary: Palette.themeColor,
      secondary: Palette.themeColor,
      surface: Palette.darkBackgroundColor,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 39, 39, 39),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Palette.blackColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSize + 6,
          fontWeight: FontWeight.bold,
          color: Palette.whiteColor,
        ),
        displayMedium: TextStyle(
          fontSize: fontSize + 4,
          fontWeight: FontWeight.w600,
          color: Palette.whiteColor,
        ),
        displaySmall: TextStyle(
          fontSize: fontSize + 2,
          fontWeight: FontWeight.w500,
          color: Palette.whiteColor,
        ),
        headlineLarge: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Palette.whiteColor,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w600,
          color: Palette.whiteColor,
        ),
        headlineSmall: TextStyle(
          fontSize: fontSize - 4,
          fontWeight: FontWeight.w500,
          color: Palette.whiteColor,
        ),
        titleLarge: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w600,
          color: Palette.whiteColor,
        ),
        titleMedium: TextStyle(
          fontSize: fontSize - 4,
          fontWeight: FontWeight.w500,
          color: Palette.whiteColor,
        ),
        titleSmall: TextStyle(
          fontSize: fontSize - 6,
          fontWeight: FontWeight.w400,
          color: Palette.whiteColor,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w400,
          color: Palette.whiteColor,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSize - 4,
          fontWeight: FontWeight.w400,
          color: Palette.whiteColor,
        ),
        bodySmall: TextStyle(
          fontSize: fontSize - 6,
          fontWeight: FontWeight.w300,
          color: Palette.whiteColor,
        ),
        labelLarge: TextStyle(
          fontSize: fontSize - 4,
          fontWeight: FontWeight.w500,
          color: Palette.whiteColor,
        ),
        labelMedium: TextStyle(
          fontSize: fontSize - 6,
          fontWeight: FontWeight.w400,
          color: Palette.whiteColor,
        ),
        labelSmall: TextStyle(
          fontSize: fontSize - 8,
          fontWeight: FontWeight.w300,
          color: Palette.whiteColor,
        ),
      ),
    ),
    iconTheme: IconThemeData(
      color: Palette.lightGreyColor,
      size: fontSize + 10,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      fillColor: Palette.greyColor,
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle(
        fontSize: fontSize,
        foregroundColor: Palette.whiteColor,
        backgroundColor: Palette.buttonColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: outlinedButtonStyle(
        fontSize: fontSize,
        foregroundColor: Palette.whiteColor,
        borderColor: Palette.buttonColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: textButtonStyle(
        foregroundColor: Palette.whiteColor,
        fontSize: fontSize,
      ),
    ),
  );
}
