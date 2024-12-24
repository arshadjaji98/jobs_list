import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryease_delivery_application/widgets/utills.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';

class Details extends StatefulWidget {
  final String image, name, details, price, id, adminId, stock, type;
  final List favourite;

  const Details({
    super.key,
    required this.image,
    required this.name,
    required this.details,
    required this.price,
    required this.stock,
    required this.id,
    required this.adminId,
    required this.type,
    required this.favourite,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int count = 1;
  bool _isLoading = false;
  late int totalPrice;
  void _addToCart() async {
    setState(() {
      _isLoading = true;
    });

    @override
    void initState() {
      super.initState();
      totalPrice = int.parse(widget.price);
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("card")
          .doc(widget.id)
          .set({
        "image": widget.image,
        "name": widget.name,
        "details": widget.details,
        "id": widget.id,
        "adminId": widget.adminId,
        "price": widget.price,
        "type": widget.type,
        "count": count,
      });

      // Show success message
      Utils.toastMessage("This Product Added to Cart");
    } catch (e) {
      // Handle any errors
      Utils.toastMessage("Failed to add product to cart: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateCount(bool isIncrement) {
    setState(() {
      if (isIncrement) {
        if (int.parse(widget.stock) >= count + 1) {
          count++;
          totalPrice = count * int.parse(widget.price);
        } else {
          Utils.toastMessage("Stock limit reached");
        }
      } else {
        if (count > 1) {
          count--;
          totalPrice = count * int.parse(widget.price);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.image,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2.5,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => const Center(
                          child: SpinKitWave(
                            color: Color(0XFF8a4af3),
                            size: 50.0,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error),
                        ),
                      ),
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.image,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 2.5,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => const Center(
                              child: SpinKitWave(
                                color: Color(0XFF8a4af3),
                                size: 50.0,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.arrow_back,
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.65),
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      if (widget.favourite.contains(FirebaseAuth
                                          .instance.currentUser!.uid)) {
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({
                                          "favourite": FieldValue.arrayRemove(
                                              [widget.id]),
                                        });
                                        FirebaseFirestore.instance
                                            .collection("products")
                                            .doc(widget.id)
                                            .update({
                                          "favourite": FieldValue.arrayRemove([
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                                .toString()
                                          ]),
                                        });
                                      } else {
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({
                                          "favourite": FieldValue.arrayUnion(
                                              [widget.id]),
                                        });
                                        FirebaseFirestore.instance
                                            .collection("products")
                                            .doc(widget.id)
                                            .update({
                                          "favourite": FieldValue.arrayUnion([
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                                .toString()
                                          ]),
                                        });
                                      }
                                      Utils.toastMessage(
                                          "Item added to favorite");
                                    },
                                    icon: Icon(Icons.favorite,
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: AppWidgets.headerTextFieldStyle(),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            count--;
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0XFF8a4af3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child:
                                const Icon(Icons.remove, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          count.toString(),
                          style: AppWidgets.boldTextFieldStyle(),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            if (int.parse(widget.stock) >= count) {
                              count++;
                              setState(() {});
                            } else {
                              print("Your Stock is $count");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0XFF8a4af3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About",
                          style: AppWidgets.boldTextFieldStyle(),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.details,
                          maxLines: 4,
                          style: AppWidgets.lightTextFieldStyle(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Similar Products",
                            style: AppWidgets.boldTextFieldStyle(),
                          ),
                          const SizedBox(height: 10),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("products")
                                .where("type", isEqualTo: widget.type)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Something went wrong!",
                                    style: AppWidgets.lightTextFieldStyle(),
                                  ),
                                );
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No similar products found.",
                                    style: AppWidgets.lightTextFieldStyle(),
                                  ),
                                );
                              }

                              final products = snapshot.data!.docs;

                              return SizedBox(
                                height: 200, // Adjust as needed
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        width: 150, // Adjust width as needed
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Stack(
                                          children: [
                                            Column(
                                              children: [
                                                Positioned(
                                                  bottom: 8,
                                                  right: 8,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      try {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection("card")
                                                            .doc(widget.id)
                                                            .set({
                                                          "image": widget.image,
                                                          "name": widget.name,
                                                          "details":
                                                              widget.details,
                                                          "id": widget.id,
                                                          "adminId":
                                                              widget.adminId,
                                                          "price": widget.price,
                                                          "type": widget.type,
                                                          "count": count,
                                                        });

                                                        // Show success message
                                                        Utils.toastMessage(
                                                            "This Product Added to Cart");
                                                      } catch (e) {
                                                        // Handle any errors
                                                        Utils.toastMessage(
                                                            "Failed to add product to cart: $e");
                                                      } finally {
                                                        setState(() {
                                                          _isLoading = false;
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 36,
                                                      width: 36,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                          Icons.add,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                CachedNetworkImage(
                                                  imageUrl: product['image'],
                                                  height: 100,
                                                  width: 150,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                    child: SpinKitWave(
                                                      color: Color(0XFF8a4af3),
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    product['name'],
                                                    style: AppWidgets
                                                        .semiBoldTextFieldStyle(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  "Rs. ${product['price']}",
                                                  style: AppWidgets
                                                      .lightTextFieldStyle(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                          onTap: _isLoading ? null : _addToCart,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rs. " + widget.price,
                                style: AppWidgets.boldTextFieldStyle(),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                  right: 5,
                                  left: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _isLoading
                                      ? Colors.grey
                                      : const Color(0XFF8a4af3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? SpinKitCircle(
                                          size: 30, color: Colors.white)
                                      : const Text(
                                          "Add To Cart",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                            fontSize: 20,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          )))
                ]))));
  }
}

class CardModel {
  List<ProductModel> productModel;
  CardModel({required this.productModel});
}

class ProductModel {
  final String image, name, description, type, adminId, id;
  final int price, stock;
  ProductModel(
      {required this.image,
      required this.name,
      required this.description,
      required this.type,
      required this.id,
      required this.adminId,
      required this.stock,
      required this.price});
}
