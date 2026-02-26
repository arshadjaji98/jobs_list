import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/firebase_options.dart';
import 'package:groceryease_delivery_application/services/auth_gate.dart';
import 'package:groceryease_delivery_application/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _lightTheme() {
    return ThemeData(
      // use a more vibrant "grocery"/"jobs" friendly teal color scheme
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // a soft off-white background gives a warmer, less stark feel
      scaffoldBackgroundColor: Colors.teal[50],
      cardTheme: const CardThemeData(color: Colors.white),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      // darker teal accents for night mode
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.tealAccent, brightness: Brightness.dark),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // dark background with a hint of teal
      scaffoldBackgroundColor: const Color(0xFF0D1F24),
      cardTheme: const CardThemeData(color: Color(0xFF1E2A2F)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.modeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          themeMode: themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}
