// ignore_for_file: use_build_context_synchronously, unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryease_delivery_application/pages/user/home.dart';
import 'package:groceryease_delivery_application/pages/super_admin/super_admin_home_screen.dart';
import 'package:groceryease_delivery_application/pages/registration/forgot_password.dart';
import 'package:groceryease_delivery_application/pages/registration/signup.dart';
import 'package:groceryease_delivery_application/responsive/web_responsive.dart';
import 'package:groceryease_delivery_application/widgets/utills.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';

import '../admin/admin_home_screen.dart';

class LogIn extends StatefulWidget {
  final void Function()? onTap;

  const LogIn({super.key, this.onTap});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  bool _isLoading = false;

  final _formkey = GlobalKey<FormState>();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  bool _isObscure = true;

  userLogin() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        setState(() {
          _isLoading = true;
        });
        final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(value.user!.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final userRole = doc.data()?['user_role'] as String?;
          if (userRole == "user") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else if (userRole == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdmin()),
            );
          } else if (userRole == "superAdmin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const SuperAdminHomeScreen()),
            );
          } else {
            Utils.toastMessage("Unknown user role.");
          }
        } else {
          Utils.toastMessage("User record not found.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LogIn()),
          );
        }
        Utils.toastMessage("Login successful! Redirecting...");
      } on FirebaseAuthException catch (e) {
        Utils.toastMessage(e.message ?? "Authentication error occurred.");
      } catch (e) {
        Utils.toastMessage("An unexpected error occurred: ${e.toString()}");
      } finally {
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
              decoration: const BoxDecoration(color: Color(0XFF8a4af3))),
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
                  const SizedBox(height: 50),
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
                                  obscureText: _isObscure,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isObscure = !_isObscure;
                                          });
                                        },
                                        icon: Icon(
                                          _isObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        )),
                                    hintText: 'Password',
                                    hintStyle:
                                        AppWidgets.semiBoldTextFieldStyle(),
                                    prefixIcon:
                                        const Icon(Icons.password_outlined),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPassword()),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    child: const Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40.0),
                                InkWell(
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
                                          ? const Center(
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
                                const SizedBox(height: 40.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUp()),
                                        );
                                      },
                                      child: const Text(
                                        "Sign up",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Home(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 200,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0XFF8a4af3),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Continue to Jobs",
                                        style: TextStyle(
                                          color: Color(0XFF8a4af3),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins1',
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
