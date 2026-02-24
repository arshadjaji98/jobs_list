import 'package:flutter/material.dart';

class AppWidgets {
  static TextStyle boldTextFieldStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.titleLarge;
    return base?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ) ??
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  }

  static TextStyle headerTextFieldStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.headlineSmall;
    return base?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ) ??
        TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  }

  static TextStyle lightTextFieldStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium;
    return base?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ) ??
        TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  }

  static TextStyle semiBoldTextFieldStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge;
    return base?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ) ??
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  }
}
