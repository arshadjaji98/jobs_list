// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/pages/admin/admin_register.dart';
import 'package:groceryease_delivery_application/pages/super_admin/admin_detail_screen.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';
import '../user/profile.dart';

class AllAdminScreen extends StatelessWidget {
  const AllAdminScreen({super.key});

  void _deleteAdmin(BuildContext context, String adminId) {
    FirebaseFirestore.instance.collection("users").doc(adminId).delete().then(
      (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Admin deleted successfully!")),
        );
      },
    ).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete admin: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index];
                  if (data["user_role"] == "admin") {
                    return Card(
                      child: ListTile(
                        leading: Text("${index + 1}"),
                        title: Text(data["name"]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Show a confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Deletion"),
                                content: const Text(
                                    "Are you sure you want to delete this admin?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      _deleteAdmin(context, data["id"]);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminDetailScreen(
                                        adminID: snapshot.data!.docs[index]
                                            ["id"],
                                      )));
                        },
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Positioned(
          bottom: 20,
          left: 15,
          right: 15,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminSignUp()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              "Add New Admin",
              style: AppWidgets.semiBoldTextFieldStyle(),
            ),
          ),
        ),
      ],
    );
  }
}
