import 'package:flutter/material.dart';
import 'palette.dart';

// Box Decorations
BoxDecoration primaryBoxDecoration({required Color color}) => BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      boxShadow: const [
        BoxShadow(
          color: Palette.greyColor,
          blurRadius: 5.0,
          spreadRadius: 1.0,
          offset: Offset(2.0, 2.0),
        ),
      ],
    );

BoxDecoration secondaryBoxDecoration({required Color color}) => BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    );

// Input Decorations
InputDecoration primaryInputDecoration(
        {required Color fillColor, String? hintText}) =>
    InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    );

InputDecoration searchInputDecoration({required Color fillColor}) =>
    primaryInputDecoration(fillColor: fillColor, hintText: 'Search...')
        .copyWith(
      prefixIcon: const Icon(Icons.search, color: Palette.iconColor),
    );

// Button Styles
ButtonStyle elevatedButtonStyle({
  required Color foregroundColor,
  required Color backgroundColor,
  required double fontSize,
}) =>
    ElevatedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.3,
        vertical: fontSize * 0.3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      minimumSize: Size(fontSize * 5, fontSize),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );

ButtonStyle outlinedButtonStyle({
  required Color foregroundColor,
  required Color borderColor,
  required double fontSize,
}) =>
    OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      side: BorderSide(color: borderColor),
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.3,
        vertical: fontSize * 0.3,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      minimumSize: Size(fontSize * 5, fontSize * 2),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );

ButtonStyle textButtonStyle({
  required Color foregroundColor,
  required double fontSize,
}) =>
    TextButton.styleFrom(
      foregroundColor: foregroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.3,
        vertical: fontSize * 0.3,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      minimumSize: Size(fontSize * 5, fontSize * 2),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );

// Icon Themes
IconThemeData iconTheme({required Color color, double size = 24.0}) =>
    IconThemeData(color: color, size: size);

// Box Decoration Theme (Custom Theme Extension)
class BoxDecorationTheme extends ThemeExtension<BoxDecorationTheme> {
  final BoxDecoration primaryDecoration;
  final BoxDecoration secondaryDecoration;

  BoxDecorationTheme({
    required this.primaryDecoration,
    required this.secondaryDecoration,
  });

  @override
  BoxDecorationTheme copyWith({
    BoxDecoration? primaryDecoration,
    BoxDecoration? secondaryDecoration,
  }) {
    return BoxDecorationTheme(
      primaryDecoration: primaryDecoration ?? this.primaryDecoration,
      secondaryDecoration: secondaryDecoration ?? this.secondaryDecoration,
    );
  }

  @override
  BoxDecorationTheme lerp(ThemeExtension<BoxDecorationTheme>? other, double t) {
    if (other is! BoxDecorationTheme) return this;
    return BoxDecorationTheme(
      primaryDecoration:
          BoxDecoration.lerp(primaryDecoration, other.primaryDecoration, t)!,
      secondaryDecoration: BoxDecoration.lerp(
          secondaryDecoration, other.secondaryDecoration, t)!,
    );
  }
}

BoxDecoration cardDecoration({
  required BuildContext context,
  double borderRadius = 8.0,
  double elevation = 4.0,
  bool isHovering = false,
}) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return BoxDecoration(
    color: isDarkMode ? Palette.darkGreyColor : Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    border: Border.all(
      color: isDarkMode
          ? Palette.lightGreyColor
          : Palette.blackColor.withOpacity(0.2),
      width: 0.5,
    ),
    boxShadow: [
      BoxShadow(
        color: isDarkMode
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.1),
        blurRadius: elevation,
        offset: Offset(0, elevation / 2),
        spreadRadius: 1,
      ),
    ],
    
  );
}

BoxDecoration boxDecoration({
  required BuildContext context,
  double borderRadius = 2.0,
  double elevation = 8.0,
  bool isHovering = false,
}) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return BoxDecoration(
    color: isDarkMode ? Palette.darkGreyColor : Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    border: Border.all(
      color:
          isDarkMode ? Palette.themeColor : Palette.blackColor.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.15),
        blurRadius: elevation,
        offset: Offset(0, elevation),
        spreadRadius: 1.5,
      ),
    ],
  );
}

class DropdownTheme {
  static const double borderRadius = 12.0;
  static const Color borderColor = Colors.grey;
  static const Color fillColor = Color(0xFFEFEFEF);
  static const TextStyle textStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  static const EdgeInsets contentPadding =
      EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0);
}
