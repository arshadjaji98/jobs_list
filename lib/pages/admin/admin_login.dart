// ignore_for_file: use_build_context_synchronously, unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryease_delivery_application/pages/admin/admin_home_screen.dart';
import 'package:groceryease_delivery_application/responsive/web_responsive.dart';
import 'package:groceryease_delivery_application/widgets/utills.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';

class AdminLogIn extends StatefulWidget {
  final void Function()? onTap;

  const AdminLogIn({super.key, this.onTap});

  @override
  State<AdminLogIn> createState() => _AdminLogInState();
}

class _AdminLogInState extends State<AdminLogIn> {
  String email = "", password = "";
  bool _isLoading = false;

  final _formkey = GlobalKey<FormState>();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  userLogin() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        setState(() {
          _isLoading = true; // Start loading
        });

        // Attempt login
        final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Fetch user document
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(value.user!.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          // Get user role
          final userRole = doc.data()?['user_role'] as String?;

          if (userRole == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdmin()),
            );
          } else {
            Utils.toastMessage("Unknown user role.");
          }
        } else {
          Utils.toastMessage("User record not found.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminLogIn()),
          );
        }

        Utils.toastMessage("Login successful! Redirecting...");
      } on FirebaseAuthException catch (e) {
        // Firebase-specific error handling
        Utils.toastMessage(e.message ?? "Authentication error occurred.");
      } catch (e) {
        // General error handling
        Utils.toastMessage("An unexpected error occurred: ${e.toString()}");
      } finally {
        // Stop loading
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: const BoxDecoration(color: Color(0XFF8a4af3)),
          ),
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: WebResponsive(
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20.0),
                                Text("Login",
                                    style: AppWidgets.headerTextFieldStyle()),
                                const SizedBox(height: 30.0),
                                TextFormField(
                                  controller: userEmailController,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please Enter Email'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle:
                                        AppWidgets.semiBoldTextFieldStyle(),
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: 30.0),
                                TextFormField(
                                  controller: userPasswordController,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please Enter Password'
                                      : null,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle:
                                        AppWidgets.semiBoldTextFieldStyle(),
                                    prefixIcon:
                                        const Icon(Icons.password_outlined),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                const SizedBox(height: 40.0),
                                GestureDetector(
                                  onTap: () {
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        email = userEmailController.text;
                                        password = userPasswordController.text;
                                      });
                                      userLogin();
                                    }
                                  },
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      width: 200,
                                      decoration: BoxDecoration(
                                        color: const Color(0XFF8a4af3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: _isLoading
                                          ? Center(
                                              child: SpinKitWave(
                                                  size: 20,
                                                  color: Colors.white))
                                          : const Center(
                                              child: Text(
                                                "LOGIN",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontFamily: 'Poppins1',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
