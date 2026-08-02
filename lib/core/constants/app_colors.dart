import 'package:flutter/material.dart';

/// Raw brand palette. Only [AppTheme] (core/theme) should reference these
/// directly — screens/widgets should read colors from `Theme.of(context)`.
abstract final class AppColors {
  static const primary = Color(0xFF9D6B3F);
  static const secondary = Color(0xFFD6B98C);
  static const backgroundLight = Color(0xFFFFFDF8);
  static const backgroundDark = Color(0xFF1E1B18);
  static const accent = Color(0xFFC99846);
  static const textLight = Color(0xFF222222);
  static const textDark = Color(0xFFF2EDE6);

  static const success = Color(0xFF3F8E5B);
  static const warning = Color(0xFFC97A18);
  static const error = Color(0xFFB3261E);
  static const errorDark = Color(0xFFF2B8B5);

  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF2A2521);
  static const outlineLight = Color(0xFFE3D9CC);
  static const outlineDark = Color(0xFF4A4238);
}
