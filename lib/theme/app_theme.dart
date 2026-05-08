import 'package:flutter/material.dart';

/// App-wide [ThemeData] holder. The full Material-3 theme (card / button /
/// input decoration overrides) lives inline in `lib/main.dart`; this class
/// kept here for screens that need the seed-colour `ColorScheme` in
/// isolation.
class AppTheme {
  static final ThemeData theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  );
}
