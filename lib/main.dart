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
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0XFF8a4af3),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: const CardThemeData(color: Colors.white),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, brightness: Brightness.dark),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF5a2ee6),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
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
