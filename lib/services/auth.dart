// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  signinWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googgleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googgleSignIn.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication?.idToken,
      accessToken: googleSignInAuthentication?.accessToken,
    );

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;
    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "email": userDetails!.email,
        'name': userDetails.displayName,
        'imageUrl': userDetails.photoURL,
        'id': userDetails.uid,
      };
    }
  }

  Future<bool> deleteUser() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        await user.delete();
        return true;
      } else {
        print("No user is signed in.");
        return false;
      }
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
  }
}
