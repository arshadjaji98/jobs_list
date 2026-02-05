import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/firebase_options.dart';
import 'package:groceryease_delivery_application/pages/user/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardThemeData(color: Colors.white),
      ),
      home: const Home(),
    );
  }
}
