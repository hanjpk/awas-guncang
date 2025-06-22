// lib/custom_color_scheme.dart
import 'package:flutter/material.dart';

class MainColorScheme {
  static ColorScheme get colorScheme => const ColorScheme(
        primary: Color.fromARGB(255, 227, 101, 92), // Custom primary color
        secondary: Colors.green, // Custom secondary color
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white,
        brightness: Brightness.light,
      );
}
