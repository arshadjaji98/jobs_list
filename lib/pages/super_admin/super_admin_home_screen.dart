import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/pages/registration/login.dart';
import 'package:groceryease_delivery_application/pages/super_admin/admin_all_products_screen.dart';
import 'package:groceryease_delivery_application/pages/super_admin/all_admin_screen.dart';
import 'package:groceryease_delivery_application/pages/super_admin/all_users_screen.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TabBar Example'),
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => LogIn()));
              },
              icon: Icon(Icons.logout),
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(CupertinoIcons.person), text: 'Users'),
              Tab(icon: Icon(CupertinoIcons.shield), text: 'Admin'),
              Tab(icon: Icon(Icons.store), text: 'All Products'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AllUsersScreen(),
            AllAdminScreen(),
            AdminAllProductsScreen()
          ],
        ),
      ),
    );
  }
}
