import 'package:flutter/material.dart';

/// The premium high-contrast design system color palette for ESCRA.
class AppColors {
  AppColors._();

  // Light themes
  static const Color background = Color(0xFFF7F7F7); 
  static const Color surface = Color(0xFFFFFFFF);    
  static const Color surfaceLight = Color(0xFFF0F0F0); 

  // Neutral contrast colors
  static const Color primary = Color(0xFF000000);     // Crisp Black
  static const Color secondary = Color(0xFF8E8E93);   // Muted Slate Gray
  static const Color silver = Color(0xFF3A3A3C);      // Dark Silver
  static const Color silverDark = Color(0xFFE5E5E7);  // Light Silver borders
  static const Color border = Color(0xFFE5E5E5);      // Grid & item dividing borders

  // Escrow state specific colors
  static const Color success = Color(0xFF34C759);     // Emerald green
  static const Color error = Color(0xFFFF453A);       // Crimson red
  static const Color warning = Color(0xFFFF9F0A);     // Gold amber
  static const Color info = Color(0xFF0A84FF);        // Royal blue

  // Sleek gradients
  static const List<Color> metallicGradient = [
    Color(0xFFE5E5E7),
    Color(0xFFF2F2F7),
    Color(0xFFAEAEB2),
    Color(0xFFE5E5E7),
  ];

  static const List<Color> obsidianGradient = [
    Color(0xFF1C1C1E),
    Color(0xFF0A0A0A),
  ];
}
