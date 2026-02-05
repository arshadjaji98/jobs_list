import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/widgets/utills.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController address = TextEditingController();

  // Helper method to check if ordering is allowed
  bool isOrderingAllowed() {
    final now = DateTime.now();
    final currentHour = now.hour;
    // Allow orders between 8 AM (hour 8) and 11 PM (hour 23)
    return currentHour >= 8 && currentHour < 23;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Cart", style: AppWidgets.boldTextFieldStyle()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection("card")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    double totalAmount =
                        snapshot.data!.docs.fold(0, (sum, doc) {
                      double price = double.parse(doc["price"].toString());
                      int count = int.parse(doc["count"].toString());
                      return sum + (price * count);
                    });
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var item = snapshot.data!.docs[index];
                              double price = double.parse(item["price"].toString());
                              int count = int.parse(item["count"].toString());
                              double totalPrice = price * count;

                              return Container(
                                height: 100,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["name"],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Rs. ${totalPrice.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                                .collection("card")
                                                .doc(item.id)
                                                .delete();
                                          },
                                          icon: const Icon(
                                            CupertinoIcons.delete,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                int count = int.parse(item["count"].toString());
                                                if (count > 1) {
                                                  FirebaseFirestore.instance
                                                      .collection("users")
                                                      .doc(FirebaseAuth.instance.currentUser!.uid)
                                                      .collection("card")
                                                      .doc(item.id)
                                                      .update({
                                                    "count": count - 1,
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons.remove_circle_outline),
                                            ),
                                            Text(
                                              item["count"].toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                int count = int.parse(item["count"].toString());
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                                    .collection("card")
                                                    .doc(item.id)
                                                    .update({
                                                  "count": count + 1,
                                                });
                                              },
                                              icon: const Icon(Icons.add_circle_outline),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Amount:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Rs. ${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Check if ordering is allowed first
                  if (!isOrderingAllowed()) {
                    Utils.toastMessage("Orders can only be placed between 8 AM and 11 PM");
                    return;
                  }
                  
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 15,
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 25),
                                    TextFormField(
                                      controller: phoneNumber,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: "Alternate Mobile Number",
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter alternate mobile number";
                                        }
                                        if (value.length < 10) {
                                          return "Enter a valid mobile number";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: address,
                                      decoration: const InputDecoration(
                                        labelText: "Confirm Address",
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter address";
                                        }
                                        return null;
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.deepPurple,
                                        ),
                                        onPressed: () async {
                                          if (!isOrderingAllowed()) {
                                            Utils.toastMessage("Orders can only be placed between 8 AM to 11 PM");
                                            return;
                                          }

                                          if (!_formKey.currentState!.validate()) {
                                            Utils.toastMessage("Please fill all the required fields!");
                                            return;
                                          }

                                          var userDoc = FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(FirebaseAuth.instance.currentUser!.uid);

                                          var cartSnapshot = await userDoc.collection("card").get();

                                          if (cartSnapshot.docs.isEmpty) {
                                            Utils.toastMessage("No items in the cart!");
                                            return;
                                          }

                                          // Proceed with order placement
                                          List<Map<String, dynamic>> items = cartSnapshot.docs
                                              .map((doc) => {
                                                    "id": doc["id"],
                                                    "adminId": doc["adminId"],
                                                    "name": doc["name"],
                                                    "price": doc["price"],
                                                    "count": doc["count"],
                                                    "details": doc["details"],
                                                    "image": doc["image"],
                                                    "type": doc["type"],
                                                    "orderType": "pending",
                                                  })
                                              .toList();

                                          final adminIds = items
                                              .map((item) => item['adminId'])
                                              .toSet();

                                          var orderId = userDoc.collection("orders").doc();

                                          await userDoc.collection("orders").doc(orderId.id).set({
                                            "orderId": orderId.id,
                                            "items": items,
                                            "totalAmount": items.fold(0, (sum, item) {
                                              return sum +
                                                  (double.parse(item["price"].toString()) *
                                                          int.parse(item["count"].toString()))
                                                      .toInt();
                                            }),
                                            "paymentMethod": "Cash",
                                            "currentAddress": address.text,
                                            "phoneNumber": phoneNumber.text,
                                            "timestamp": FieldValue.serverTimestamp(),
                                          });

                                          for (var adminId in adminIds) {
                                            final itemsForAdmin = items
                                                .where((item) => item['adminId'] == adminId)
                                                .toList();

                                            final totalAmount = itemsForAdmin.fold(0, (sum, item) {
                                              return sum +
                                                  (double.parse(item["price"].toString()) *
                                                          int.parse(item["count"].toString()))
                                                      .toInt();
                                            });

                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(adminId)
                                                .collection("orders")
                                                .doc(orderId.id)
                                                .set({
                                              "items": itemsForAdmin,
                                              "totalAmount": totalAmount,
                                              "paymentMethod": "Cash",
                                              "currentAddress": address.text,
                                              "phoneNumber": phoneNumber.text,
                                              "timestamp": FieldValue.serverTimestamp(),
                                              "userId": FirebaseAuth.instance.currentUser!.uid,
                                            });
                                          }

                                          // Clear the cart
                                          final collectionRef = userDoc.collection("card");
                                          final querySnapshot = await collectionRef.get();

                                          for (var doc in querySnapshot.docs) {
                                            await doc.reference.delete();
                                          }

                                          Navigator.pop(context);
                                        },
                                        child: const Text("Order Now"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}