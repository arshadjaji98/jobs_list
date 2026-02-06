import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryease_delivery_application/pages/user/full_screen.dart';
import 'package:groceryease_delivery_application/widgets/utills.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class Details extends StatefulWidget {
  final String image, name, details, price, id, adminId, stock, type;
  final String location, vacancies;
  final List favourite;
  final Timestamp? postedDate;

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
    required this.location,
    required this.vacancies,
    required this.favourite,
    required this.postedDate,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int count = 1;
  bool isSaved = false;
  @override
  void initState() {
    super.initState();
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      final currentUser = current.uid;
      isSaved = widget.favourite.contains(currentUser);
    } else {
      isSaved = false;
    }
  }

  Future<void> toggleSaveJob() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Utils.toastMessage("Please sign in to save jobs");
      return;
    }
    final userId = user.uid;
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
    final productRef =
        FirebaseFirestore.instance.collection("products").doc(widget.id);

    if (isSaved) {
      // Unsave job
      await userRef.update({
        "favourite": FieldValue.arrayRemove([widget.id]),
      });
      await productRef.update({
        "favourite": FieldValue.arrayRemove([userId]),
      });
      Utils.toastMessage("Job removed from saved list");
    } else {
      // Save job
      await userRef.update({
        "favourite": FieldValue.arrayUnion([widget.id]),
      });
      await productRef.update({
        "favourite": FieldValue.arrayUnion([userId]),
      });
      Utils.toastMessage("Job saved successfully");
    }

    // Update UI immediately
    setState(() {
      isSaved = !isSaved;
    });
  }

  String cleanPriceString(String price) {
    return price.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String getTotalPrice() {
    String cleanedPrice = cleanPriceString(widget.price);
    return (int.parse(cleanedPrice) * count).toString();
  }

  /// Format raw date like "23092025" → "23 September 2025"
  String formatDate(String rawDate) {
    try {
      DateTime parsedDate = DateFormat("ddMMyyyy").parse(rawDate);
      return DateFormat("dd MMMM yyyy").format(parsedDate);
    } catch (e) {
      return rawDate; // fallback if parsing fails
    }
  }

  String formatPostedDate(Timestamp? ts) {
    if (ts == null) return 'Unknown';
    try {
      final dt = ts.toDate();
      return DateFormat('dd MMMM yyyy').format(dt);
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _onOpen(LinkableElement link) async {
    final Uri url = Uri.parse(link.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Image: ${widget.image}");
    return Scaffold(
      backgroundColor: const Color(0XFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImage(imageUrl: widget.image),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.image,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 2.5,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SpinKitWave(
                            color: Color(0XFF8a4af3),
                            size: 50.0,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF181725),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Last Date:",
                          style: AppWidgets.semiBoldTextFieldStyle()),
                      Text(
                        formatDate(widget.price), // formatted date
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Location:",
                          style: AppWidgets.semiBoldTextFieldStyle()),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0XFF8a4af3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Vacancies:",
                          style: AppWidgets.semiBoldTextFieldStyle()),
                      Text(
                        widget.vacancies,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0XFF8a4af3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Posted Date:",
                          style: AppWidgets.semiBoldTextFieldStyle()),
                      Text(
                        formatPostedDate(widget.postedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0XFF181725),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Job Description",
                    style: AppWidgets.boldTextFieldStyle(),
                  ),
                  const SizedBox(height: 8),
                  Linkify(
                    onOpen: _onOpen,
                    text: widget.details,
                    style: AppWidgets.lightTextFieldStyle(),
                    linkStyle: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSaved ? Colors.grey : const Color(0XFF8a4af3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: toggleSaveJob,
              icon: Icon(
                isSaved ? Icons.bookmark_added : Icons.bookmark_border,
                color: Colors.white,
              ),
              label: Text(
                isSaved ? "Job Saved" : "Save Job",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
