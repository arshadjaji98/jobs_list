// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/user/bottom_nav_bar.dart';
import '../pages/registration/login.dart';

class SplashService {
  Future<void> isSplash(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        var doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          String? userRole = doc.data()?['user_role'];
          if (userRole == "user") {
            Future.delayed(
                const Duration(seconds: 3),
                () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BottomNav())));
          } else {
            Future.delayed(
                const Duration(seconds: 3),
                () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LogIn())));
          }
        } else {
          Future.delayed(
              const Duration(seconds: 3),
              () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LogIn())));
        }
      } catch (e) {
        debugPrint("Error: $e");
        Future.delayed(
            const Duration(seconds: 3),
            () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LogIn())));
      }
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LogIn()));
      });
    }
  }
}
