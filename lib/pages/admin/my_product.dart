import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/widgets/utills.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  String? selectedCategory;
  List<String> categories = [
    "Fruit",
    "Meat",
    "Bakery",
    "Beverages",
    "Oil",
    "Vegetables",
    "Dry Fruits",
    "Snacks",
    "Honey"
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
                    .where("adminId",
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Qty: " + foodItem["quantity"].toString()),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _openEditDialog(context, foodItem);
                              },
                            ),
                          ],
                        ),
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

  void _openEditDialog(BuildContext context, DocumentSnapshot foodItem) {
    final TextEditingController nameController =
        TextEditingController(text: foodItem['name']);
    final TextEditingController priceController =
        TextEditingController(text: foodItem['price'].toString());
    final TextEditingController quantityController =
        TextEditingController(text: foodItem['quantity'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Product"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantity"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("products")
                  .doc(foodItem.id)
                  .update({
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'quantity': int.tryParse(quantityController.text) ?? 0,
              }).then((value) {
                Navigator.pop(context);
                Utils.toastMessage("Product updated successfully!");
              }).catchError((error) {
                Utils.toastMessage("Failed to update product: $error");
              });
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
