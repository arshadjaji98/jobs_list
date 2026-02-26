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

  String cleanPriceString(String price) {
    return price.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String getTotalPrice() {
    String cleanedPrice = cleanPriceString(widget.price);
    return (int.parse(cleanedPrice) * count).toString();
  }

  String formatDate(String rawDate) {
    try {
      DateTime parsedDate = DateFormat("ddMMyyyy").parse(rawDate);
      return DateFormat("dd MMMM yyyy").format(parsedDate);
    } catch (e) {
      return rawDate;
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

  Future<void> toggleSaveJob(bool isSaved) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Utils.toastMessage("Please sign in to save jobs", context: context);
      return;
    }
    final userId = user.uid;
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
    final productRef =
        FirebaseFirestore.instance.collection("products").doc(widget.id);

    if (isSaved) return; // already saved, do nothing

    await userRef.update({
      "favourite": FieldValue.arrayUnion([widget.id]),
    });
    await productRef.update({
      "favourite": FieldValue.arrayUnion([userId]),
    });

    Utils.toastMessage("Job saved successfully", context: context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        placeholder: (context, url) => Center(
                          child: SpinKitWave(
                            color: Theme.of(context).colorScheme.primary,
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
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Theme.of(context).iconTheme.color),
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: AppWidgets.boldTextFieldStyle(context),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Last Date:",
                          style: AppWidgets.semiBoldTextFieldStyle(context)),
                      Text(
                        formatDate(widget.price),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Location:",
                          style: AppWidgets.semiBoldTextFieldStyle(context)),
                      Text(
                        widget.location,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Vacancies:",
                          style: AppWidgets.semiBoldTextFieldStyle(context)),
                      Text(
                        widget.vacancies,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Posted Date:",
                          style: AppWidgets.semiBoldTextFieldStyle(context)),
                      Text(
                        formatPostedDate(widget.postedDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Job Description",
                    style: AppWidgets.boldTextFieldStyle(context),
                  ),
                  const SizedBox(height: 8),
                  Linkify(
                    onOpen: _onOpen,
                    text: widget.details,
                    style: AppWidgets.lightTextFieldStyle(context),
                    linkStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: currentUser == null
          ? const SizedBox.shrink()
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator()));
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final favourites =
                    List<String>.from(userData['favourite'] ?? []);
                final isSaved = favourites.contains(widget.id);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSaved
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaved ? null : () => toggleSaveJob(isSaved),
                      icon: Icon(
                        isSaved ? Icons.bookmark_added : Icons.bookmark_border,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      label: Text(
                        isSaved ? "Job Saved" : "Save Job",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
