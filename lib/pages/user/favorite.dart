import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryease_delivery_application/pages/user/details.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';
import 'package:page_transition/page_transition.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  String _searchQuery = '';
  String? selectType;
  Stream<QuerySnapshot> getFilteredProducts() {
    final collection =
        FirebaseFirestore.instance.collection("products").limit(20);

    if (_searchQuery.isNotEmpty) {
      return collection
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThan: _searchQuery + 'z')
          .snapshots();
    }

    if (selectType != null) {
      return collection.where("type", isEqualTo: selectType).snapshots();
    }

    return collection.snapshots();
  }

  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please log in to view your favorite items."),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:
            const Text("My Favourite", style: TextStyle(color: Colors.black)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            List<dynamic> favouriteIds = userSnapshot.data!["favourite"] ?? [];

            if (favouriteIds.isEmpty) {
              return const Center(
                child: Text(
                  "No Job Saved.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            }
            return StreamBuilder(
              stream: getFilteredProducts(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitWave(color: Color(0XFF8a4af3), size: 30.0),
                  );
                }
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? "No current job available"
                          : "No job found for '$_searchQuery'",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    if (!favouriteIds.contains(ds["id"])) {
                      return const SizedBox.shrink();
                    }
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                alignment: Alignment.center,
                                duration: const Duration(milliseconds: 400),
                                child: Details(
                                  image: ds['image'],
                                  name: ds['name'],
                                  details: ds['detail'],
                                  price: ds['price'].toString(),
                                  id: ds['id'],
                                  stock: ds['quantity'].toString(),
                                  adminId: ds['adminId'],
                                  type: ds['type'],
                                  location: ds['location'],
                                  vacancies: ds['vacancies'],
                                  favourite: [],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: ds["image"],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                          color: Colors.grey[200], height: 180),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error, size: 50),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ds["name"],
                                          style:
                                              AppWidgets.boldTextFieldStyle(),
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 18,
                                                color: Colors.black54),
                                            const SizedBox(width: 6),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Last Date: ",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  ds["price"],
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    size: 18,
                                                    color: Colors.black54),
                                                const SizedBox(width: 4),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Location: ",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      ds["location"],
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0XFF5d2ee6),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.people,
                                                    size: 18,
                                                    color: Colors.black54),
                                                const SizedBox(width: 4),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Vacancies: ",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      ds["vacancies"],
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0XFF5d2ee6),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0XFF8a4af3),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: Icon(
                                                Icons.bookmark_remove_outlined,
                                                size: 18,
                                                color: Colors.white),
                                            label: const Text("Unsave"),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser!.uid)
                                                  .update({
                                                "favourite":
                                                    FieldValue.arrayRemove(
                                                        [ds["id"]])
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
