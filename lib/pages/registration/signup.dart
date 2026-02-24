import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryease_delivery_application/pages/user/home.dart';
import 'package:groceryease_delivery_application/pages/registration/login.dart';
import 'package:groceryease_delivery_application/responsive/web_responsive.dart';
import 'package:groceryease_delivery_application/widgets/utills.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';

class SignUp extends StatefulWidget {
  final void Function()? onTap;
  const SignUp({super.key, this.onTap});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String selectType = "user";

  final _formkey = GlobalKey<FormState>();

  registration() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      )
          .then((value) {
        Map<String, dynamic> addUserInfo = {
          "name": nameController.text.trim(),
          "email": value.user!.email.toString(),
          "wallet": "0",
          "phone": phoneController.text,
          "id": value.user!.uid,
          "favourite": [],
          "profile_image": "",
          "user_role": selectType,
          "date": DateTime.now(),
          "verify": true,
        };
        FirebaseFirestore.instance
            .collection("users")
            .doc(value.user!.uid)
            .set(addUserInfo);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
        Utils.toastMessage("Registered Successfully");
      }).onError((e, s) {
        Utils.toastMessage(e.toString());
      });
    } on FirebaseAuthException catch (e) {
      Utils.toastMessage(e.toString());
    } catch (e) {
      Utils.toastMessage(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              decoration: const BoxDecoration(
                color: Color(0XFF8a4af3),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: WebResponsive(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Form(
                                    key: _formkey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 20.0),
                                        Text(
                                          "Sign Up",
                                          style:
                                              AppWidgets.headerTextFieldStyle(
                                                  context),
                                        ),
                                        const SizedBox(height: 30.0),
                                        TextFormField(
                                          controller: nameController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Name';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Name',
                                            hintStyle: AppWidgets
                                                .semiBoldTextFieldStyle(
                                                    context),
                                            prefixIcon: const Icon(
                                                Icons.person_outlined),
                                          ),
                                        ),
                                        const SizedBox(height: 30.0),
                                        TextFormField(
                                          controller: emailController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter E-mail';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              hintText: 'Email',
                                              hintStyle: AppWidgets
                                                  .semiBoldTextFieldStyle(
                                                      context),
                                              prefixIcon: const Icon(
                                                  Icons.email_outlined)),
                                        ),
                                        const SizedBox(height: 30.0),
                                        TextFormField(
                                          controller: passwordController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Password';
                                            }
                                            return null;
                                          },
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              hintText: 'Password',
                                              hintStyle: AppWidgets
                                                  .semiBoldTextFieldStyle(
                                                      context),
                                              prefixIcon: const Icon(
                                                  Icons.password_outlined)),
                                        ),
                                        const SizedBox(height: 20.0),
                                        InkWell(
                                          onTap: () async {
                                            if (_formkey.currentState!
                                                .validate()) {
                                              setState(() {});
                                              await registration();
                                            }
                                          },
                                          child: Material(
                                            elevation: 5.0,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              width: 200,
                                              decoration: BoxDecoration(
                                                color: const Color(0XFF8a4af3),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: _isLoading
                                                  ? const Center(
                                                      child: SpinKitWave(
                                                          size: 20,
                                                          color: Colors.white))
                                                  : const Center(
                                                      child: Text(
                                                        "SIGN IN",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18.0,
                                                          fontFamily:
                                                              'Poppins1',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Already have an account? ",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                              ),
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LogIn()));
                                                },
                                                child: const Text("Login",
                                                    style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 18,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
