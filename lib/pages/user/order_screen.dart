import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future<void> cancelOrder(String orderId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Delete the order from Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("orders")
          .doc(orderId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order canceled successfully")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel order: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Your Orders", style: AppWidgets.boldTextFieldStyle()),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("orders")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No orders found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderData = snapshot.data!.docs[index];
              final orderId = orderData.id; // Get the order ID
              DateTime dateTime =
                  (orderData["timestamp"] as Timestamp).toDate();
              var orderDate = DateFormat('dd-MM-yyyy').format(dateTime);

              return Card(
                child: ExpansionTile(
                  title: Text(orderDate,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Colors.grey)),
                  subtitle: Text(orderData["paymentMethod"],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black)),
                  trailing: Text("Rs. " + orderData["totalAmount"].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black)),
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: orderData["items"].length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            leading: Text("${i + 1}"),
                            title: Text(
                              orderData["items"][i]["name"],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                            subtitle: Text(orderData["items"][i]["orderType"]),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Rs. " + orderData["items"][i]["price"]),
                                Text("Qty. " +
                                    orderData["items"][i]["count"].toString()),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {
                          cancelOrder(
                              orderId); // Call the cancel order function
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.grey[200],
                        ),
                        child: Text("Cancel Order"),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
