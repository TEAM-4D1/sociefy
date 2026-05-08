import 'package:flutter/material.dart';
import 'colours.dart';

/// Centralised text style constants used across the app, so headings,
/// body text and captions stay visually consistent without each screen
/// hand-rolling its own [TextStyle].
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColours.textDark,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColours.textDark,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    color: AppColours.textDark,
  );

  static const TextStyle bodyGrey = TextStyle(
    fontSize: 14,
    color: AppColours.textGrey,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColours.textGrey,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
