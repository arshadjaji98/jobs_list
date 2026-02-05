import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/pages/user/order_screen.dart';
import 'package:groceryease_delivery_application/pages/user/profile.dart';
import 'package:groceryease_delivery_application/pages/user/favorite.dart';
import 'home.dart';
import 'order.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTab = 0;
  Widget getPage(int index) {
    switch (index) {
      case 0:
        return const Home(
          favourite: [],
        );
      case 1:
        return const Cart();
      case 2:
        return const OrderScreen();
      case 3:
        return const Favorite();
      case 4:
        return const Profile();
      default:
        return const Home();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: const Color(0XFF8a4af3),
        animationDuration: const Duration(milliseconds: 300),
        onTap: (int index) {
          setState(() {
            currentTab = index;
          });
        },
        items: const [
          Icon(CupertinoIcons.home, color: Colors.white),
          Icon(CupertinoIcons.bag, color: Colors.white),
          Icon(CupertinoIcons.cube_box, color: Colors.white),
          Icon(CupertinoIcons.heart, color: Colors.white),
          Icon(Icons.local_offer, color: Colors.white)
        ],
      ),
      body: getPage(currentTab),
    );
  }
}
