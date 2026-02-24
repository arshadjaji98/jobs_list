import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/pages/user/details.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';

class CategoryJobsScreen extends StatefulWidget {
  final String category;

  const CategoryJobsScreen({super.key, required this.category});

  @override
  State<CategoryJobsScreen> createState() => _CategoryJobsScreenState();
}

class _CategoryJobsScreenState extends State<CategoryJobsScreen> {
  String _searchQuery = '';

  Stream<QuerySnapshot> getCategoryStream() {
    try {
      Query collection = FirebaseFirestore.instance
          .collection('products')
          .where('type', isEqualTo: widget.category)
          .orderBy('timestamp', descending: true);

      // Add a short timeout so the UI doesn't stay in a perpetual waiting state
      // if the stream is stuck. On timeout we close the stream which lets the
      // builder show an empty-state message.
      return collection.snapshots().handleError((error) {
        if (kDebugMode) print('Firestore error: $error');
      }).timeout(const Duration(seconds: 5), onTimeout: (sink) {
        if (kDebugMode)
          print('Firestore stream timeout for category ${widget.category}');
        sink.close();
      });
    } catch (e) {
      if (kDebugMode) print('Stream creation error: $e');
      return const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(widget.category),
        backgroundColor: const Color(0XFF8a4af3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search in category',
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getCategoryStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  // If the stream is still waiting but produced no data yet,
                  // show a loader. If the stream finished or is active and
                  // there are no documents, show an empty-state message.
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      docs.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final filtered = docs.where((doc) {
                    if (_searchQuery.isEmpty) return true;
                    final name = (doc['name'] ?? '').toString().toLowerCase();
                    final detail =
                        (doc['detail'] ?? '').toString().toLowerCase();
                    final q = _searchQuery.toLowerCase();
                    return name.contains(q) || detail.contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('No jobs in ${widget.category}'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ds = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Details(
                                  image: ds['image'],
                                  name: ds['name'],
                                  details: ds['detail'],
                                  price: ds['price'].toString(),
                                  id: ds['id'],
                                  stock: ds['quantity'].toString(),
                                  adminId: ds['adminId'],
                                  type: ds['type'],
                                  location: ds['location'],
                                  postedDate: ds['timestamp'],
                                  vacancies: ds['vacancies'],
                                  favourite: const [],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    height: 80,
                                    width: 100,
                                    child: CachedNetworkImage(
                                      imageUrl: ds['image'] ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (c, u) =>
                                          Container(color: Colors.grey[200]),
                                      errorWidget: (c, u, e) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ds['name'] ?? '',
                                          style:
                                              AppWidgets.boldTextFieldStyle()),
                                      const SizedBox(height: 6),
                                      Text(
                                        ds['location'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
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
}
