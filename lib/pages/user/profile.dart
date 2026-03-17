import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/pages/registration/login.dart';
import 'package:groceryease_delivery_application/services/database_services.dart';
import 'package:groceryease_delivery_application/widgets/utills.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class Profile extends StatefulWidget {
  const Profile({this.userRole, this.userId, super.key});
  final String? userId;
  final String? userRole;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  File? selectedResume;
  String? resumeUrl;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {
        uploadItem();
      });
    }
  }

  Future getResume() async {
    var file = await _picker.pickImage(
        source: ImageSource
            .gallery); // For simplicity, using image picker; in real app, use file picker for PDFs
    if (file != null) {
      selectedResume = File(file.path);
      setState(() {
        uploadResume();
      });
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("profileImages").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downloadUrl = await (await task).ref.getDownloadURL();

      // Add cache buster to force image reload
      String cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
      String updatedUrl = "$downloadUrl?v=$cacheBuster";

      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "profile_image": updatedUrl,
      });

      setState(() {});
    }
  }

  uploadResume() async {
    if (selectedResume != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("resumes").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedResume!);

      var downloadUrl = await (await task).ref.getDownloadURL();

      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "resume_url": downloadUrl,
      });

      setState(() {
        resumeUrl = downloadUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Profile",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: true,
        actions: [
          // Only show logout if user is logged in
          if (widget.userId != null ||
              FirebaseAuth.instance.currentUser != null)
            IconButton(
              icon: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.onPrimary),
              onPressed: () async {
                bool? confirmLogout = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Logout"),
                    content: const Text("Do you really want to log out?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("No")),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Yes")),
                    ],
                  ),
                );
                if (confirmLogout == true) {
                  await DatabaseServices().signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LogIn()),
                      (route) => false);
                }
              },
            )
        ],
      ),
      body: widget.userId == null && FirebaseAuth.instance.currentUser == null
          ? Center(
              child: Text(
                "User not logged in",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.userId ?? FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: data["profile_image"] != null
                                    ? NetworkImage(data["profile_image"])
                                    : null,
                                child: data["profile_image"] == null
                                    ? Icon(Icons.person,
                                        size: 60,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: IconButton(
                                    icon: Icon(Icons.camera_alt,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                    onPressed: getImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (widget.userId != null ||
                            FirebaseAuth.instance.currentUser != null)
                          _buildChangePasswordCard(context),
                        _buildEditableInfoCard(
                            Icons.person, "Your Name", data["name"], "name"),
                        _buildEditableInfoCard(
                            Icons.email, "Your Email", data["email"], "email"),
                        _buildEditableInfoCard(
                            Icons.info, "Bio", data["bio"], "bio"),
                        _buildEditableInfoCard(
                            Icons.work, "Skills", data["skills"], "skills"),
                        _buildEditableInfoCard(Icons.work_outline, "Experience",
                            data["experience"], "experience"),
                        _buildResumeCard(context, data["resume_url"]),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }

  Widget _buildEditableInfoCard(
      IconData icon, String label, String? value, String field) {
    return GestureDetector(
      onTap: () => _editField(context, label, value ?? "", field),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child:
                    Icon(icon, color: Theme.of(context).colorScheme.onPrimary)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    value ?? "Not set",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context, String? resumeUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.description,
                  color: Theme.of(context).colorScheme.onPrimary)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Resume",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  resumeUrl != null ? "Uploaded" : "Not uploaded",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.upload,
                color: Theme.of(context).colorScheme.primary),
            onPressed: getResume,
          ),
        ],
      ),
    );
  }

  void _editField(BuildContext context, String label, String currentValue,
      String field) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    String? newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $label"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
    if (newValue != null && newValue != currentValue) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({field: newValue});
    }
  }
}

Widget _buildChangePasswordCard(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      TextEditingController passwordController = TextEditingController();

      bool? changed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Change Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Enter new password",
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () async {
                  String newPassword = passwordController.text.trim();
                  if (newPassword.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password must be at least 6 characters"),
                      ),
                    );
                    return;
                  }
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await user.updatePassword(newPassword);
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Change")),
          ],
        ),
      );

      if (changed == true) {
        Utils.toastMessage("Password changed successfully", context: context);
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.lock,
                  color: Theme.of(context).colorScheme.onPrimary)),
          const SizedBox(width: 16),
          Text(
            "Change Password",
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
