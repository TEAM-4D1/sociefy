import 'package:flutter/material.dart';

/// App-wide named colour constants. Screens reference these instead of
/// inlining hex literals so re-skinning is a single-file change.
class AppColours {
  static const Color primaryPurple = Color(0xFF4A148C);
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color successGreen = Color(0xFF43A047);
}
