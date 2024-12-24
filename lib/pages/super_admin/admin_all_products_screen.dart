import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';

class AdminAllProductsScreen extends StatefulWidget {
  const AdminAllProductsScreen({super.key});

  @override
  State<AdminAllProductsScreen> createState() => _AdminAllProductsScreenState();
}

class _AdminAllProductsScreenState extends State<AdminAllProductsScreen> {
  List<String> types = ["Fruit", "Meat", "Bakery", "Beverages", "Oil"];
  String? selectType;

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product deleted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete product: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProduct(
      String productId, String name, double price, String type) async {
    try {
      // Ensure all fields are not empty before updating
      if (name.isEmpty || type.isEmpty || price <= 0) {
        throw "Invalid product details.";
      }

      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .update({
        "name": name,
        "price": price,
        "type": type,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update product: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: const Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteProduct(productId); // Delete the product
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String productId, String name, double price, String type,
      String imageUrl) {
    final nameController = TextEditingController(text: name);
    final priceController = TextEditingController(text: price.toString());
    String selectedType = type;

    // Ensure the current type is part of the dropdown options
    if (!types.contains(type)) {
      types.add(type);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: types.contains(selectedType) ? selectedType : null,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                  hint: const Text("Select a category"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedName = nameController.text.trim();
                final updatedPrice =
                    double.tryParse(priceController.text.trim());
                if (updatedName.isNotEmpty && updatedPrice != null) {
                  await _updateProduct(
                      productId, updatedName, updatedPrice, selectedType);
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please fill all fields correctly")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("products")
          .where("type", isEqualTo: selectType)
          .snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitWave(color: Color(0XFF8a4af3), size: 30.0),
          );
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(
            child: Text(
              "No items available",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
              child: Material(
                elevation: 5,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: ds["image"],
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const LinearProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ds["name"],
                              style: AppWidgets.semiBoldTextFieldStyle(),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Fresh and Healthy",
                              style: AppWidgets.lightTextFieldStyle(),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Rs. ${ds["price"]}",
                              style: AppWidgets.semiBoldTextFieldStyle(),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditDialog(
                                ds.id,
                                ds["name"],
                                ds["price"],
                                ds["type"],
                                ds["image"],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteDialog(ds.id);
                            },
                          ),
                        ],
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
  }
}
