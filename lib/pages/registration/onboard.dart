// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/pages/registration/signup.dart';
import 'package:groceryease_delivery_application/widgets/content_model.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';

class Onboard extends StatefulWidget {
  final void Function()? onTap;
  const Onboard({super.key, this.onTap});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                // Prevent horizontal drag (swipe)
                if (details.delta.dx > 0 || details.delta.dx < 0) {
                  return; // Do nothing, prevent swipe
                }
              },
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Column(
                      children: [
                        Image.asset(
                          contents[i].image,
                          height: 450,
                          width: 350,
                          fit: BoxFit.fill,
                        ),
                        Text(
                          contents[i].title,
                          style: AppWidgets.headerTextFieldStyle().copyWith(
                            fontSize:
                                screenHeight * 0.03, // Responsive text size
                          ),
                        ),
                        Text(
                          contents[i].description,
                          style: AppWidgets.lightTextFieldStyle().copyWith(
                            fontSize:
                                screenHeight * 0.02, // Responsive text size
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => buildDot(index, context),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (currentIndex == contents.length - 1) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignUp()));
              }
              _controller.nextPage(
                  duration: Duration(milliseconds: 100),
                  curve: Curves.bounceIn);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0XFF8a4af3),
                borderRadius: BorderRadius.circular(20),
              ),
              height: 60,
              margin: EdgeInsets.all(40),
              width: 200,
              child: Center(
                child: Text(
                  currentIndex == contents.length - 1 ? "Start" : "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.025, // Responsive text size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10.0,
      width: currentIndex == index ? 18 : 7,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), color: Colors.black38),
    );
  }
}
