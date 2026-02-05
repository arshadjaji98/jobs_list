import 'package:flutter/material.dart';

class AppWidgets {
  static TextStyle boldTextFieldStyle() {
    return const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins');
  }

  static TextStyle headerTextFieldStyle() {
    return const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins');
  }

  static TextStyle lightTextFieldStyle() {
    return const TextStyle(
        color: Colors.black38,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins');
  }

  static TextStyle semiBoldTextFieldStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontFamily: 'Poppins',
    );
  }
}
