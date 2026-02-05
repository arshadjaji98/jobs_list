import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllProductsDetail extends StatefulWidget {
  const AllProductsDetail({required this.adminId, super.key});
  final String adminId;
  @override
  State<AllProductsDetail> createState() => _AllProductsDetailState();
}

class _AllProductsDetailState extends State<AllProductsDetail> {
  String? selectedCategory;
  final List<String> categories = [
    'Fruit',
    'Meat',
    'Beverages',
    'Bakery',
    'Oil'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Your Products"),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              hint: const Text("Select Category"),
              value: selectedCategory,
              isExpanded: true,
              padding: const EdgeInsets.only(left: 10),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .where("adminId", isEqualTo: widget.adminId)
                    .where("type", isEqualTo: selectedCategory)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text(
                      "No items found",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ));
                  }

                  var foodItems = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final foodItem = foodItems[index];
                      return ListTile(
                        leading: foodItem['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  foodItem['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.fastfood),
                        title: Text(foodItem['name']),
                        subtitle: Text("Rs. " + foodItem['price'].toString()),
                        trailing:
                            Text("Quantity " + foodItem["quantity"].toString()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
