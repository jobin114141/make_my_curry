import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/app_constants.dart';

const Color pesitoPrimary = Color(0xFFC70043);
const Color pesitoSecondary = Color(0xFFFFE4EF); // Soft, light pink
const Color pesitoCard = Colors.white;
const Color pesitoFocus = Color(0xFFF4A6BB); // Lighter pinkish for focus
const Color pesitoHint = Color(0xFFAD4066); // Muted, deep pinkish for hints
const Color pesitoCanvas = Color(0xFFFFF6F9); // Very light, for backgrounds
const Color pesitoShadow = Color(0x1AC70043); // Slight shadow using primary

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: pesitoPrimary,
  secondaryHeaderColor: pesitoSecondary,
  brightness: Brightness.light,
  cardColor: pesitoCard,
  focusColor: pesitoFocus,
  hintColor: pesitoHint,
  canvasColor: pesitoCanvas,
  shadowColor: pesitoShadow,
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: pesitoPrimary, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Color(0xFF303030)), // Main text color
  ),
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
  popupMenuTheme:
      const PopupMenuThemeData(color: pesitoCard, surfaceTintColor: pesitoCard),
  dialogTheme: const DialogThemeData(
      backgroundColor: pesitoCard, surfaceTintColor: pesitoCard),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: pesitoPrimary,
    onPrimary: Colors.white,
    secondary: pesitoSecondary,
    onSecondary: pesitoPrimary,
    error: Colors.redAccent,
    onError: Colors.white,
    surface: pesitoCard,
    onSurface: pesitoPrimary,
    shadow: pesitoShadow,
  ),
);
