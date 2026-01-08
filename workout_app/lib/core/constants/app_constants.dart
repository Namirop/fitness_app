import 'package:flutter/material.dart';

class AppBorderRadius {
  static const small = 10.0;
  static const medium = 18.0;
  static const large = 25.0;
}

class AppColors {
  static const screenBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 238, 228, 206),
      Color.fromARGB(255, 243, 239, 227),
    ],
  );
  static const widgetBackground = Color.fromARGB(155, 255, 255, 255);
  static const buttonColor = Color.fromARGB(255, 68, 62, 62);
  static const containerBorderColor = Color.fromARGB(52, 121, 85, 72);
  static const bottomSheetColor = Color.fromARGB(255, 243, 241, 235);
}
