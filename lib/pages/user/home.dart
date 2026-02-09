import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryease_delivery_application/pages/registration/login.dart';
import 'package:groceryease_delivery_application/pages/user/details.dart';
import 'package:groceryease_delivery_application/pages/user/favorite.dart';
import 'package:groceryease_delivery_application/pages/user/profile.dart';
import 'package:groceryease_delivery_application/pages/user/announcements.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  final List? favourite;

  const Home({super.key, this.favourite});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? username;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> categories = [
    {"name": "Forces Jobs", "icon": Icons.security},
    {"name": "Govt Jobs", "icon": Icons.account_balance},
    {"name": "Private Jobs", "icon": Icons.business_center},
    {"name": "Semi-Govt Jobs", "icon": Icons.apartment},
    {"name": "Others", "icon": Icons.more_horiz},
  ];

  String? selectType;
  String _sortOrder = 'Latest';

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  String formatPostedDate(dynamic ts) {
    if (ts == null) return 'Unknown';
    try {
      if (ts is Timestamp) {
        return DateFormat('dd MMMM yyyy').format(ts.toDate());
      }
      if (ts is DateTime) return DateFormat('dd MMMM yyyy').format(ts);
      if (ts is int) {
        return DateFormat('dd MMMM yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(ts));
      }
      return ts.toString();
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsername() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        setState(() {
          username = userDoc.data()?['name'] ?? 'User';
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Stream<QuerySnapshot> getFilteredProducts() {
    Query collection = FirebaseFirestore.instance.collection("products");

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      collection = collection
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThan: _searchQuery + 'z');
    }

    // Filter by type
    if (selectType != null) {
      collection = collection.where("type", isEqualTo: selectType);
    }

    // Sort by Latest or Oldest
    if (_sortOrder == 'Latest') {
      collection = collection.orderBy('timestamp', descending: true);
    } else {
      collection = collection.orderBy('timestamp', descending: false);
    }

    // Limit results
    collection = collection.limit(20);

    return collection.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      drawer: SafeArea(
        child: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Image.asset('assets/images/Logo.jpg')),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        FirebaseAuth.instance.currentUser != null
                            ? 'Hello, ${username ?? 'User'}'
                            : 'Welcome, Guest',
                        style: const TextStyle(
                          color: Color(0XFF8a4af3),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.work_outline,
                  color: selectType == null
                      ? const Color(0XFF8a4af3)
                      : Colors.black54,
                ),
                title: Text(
                  "All Jobs",
                  style: TextStyle(
                    fontWeight: selectType == null
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectType == null
                        ? const Color(0XFF8a4af3)
                        : Colors.black87,
                  ),
                ),
                selected: selectType == null,
                selectedTileColor: const Color(0XFFECECF8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  setState(() {
                    selectType = null;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  Navigator.pop(context);
                },
              ),
              // Announcements link
              ListTile(
                leading: const Icon(Icons.announcement, color: Colors.black54),
                title: const Text('Announcements'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Announcements()),
                  );
                },
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: categories.map((cat) {
                    return ListTile(
                      leading: Icon(
                        cat["icon"],
                        color: selectType == cat["name"]
                            ? const Color(0XFF8a4af3)
                            : Colors.black54,
                      ),
                      title: Text(
                        cat["name"],
                        style: TextStyle(
                          fontWeight: selectType == cat["name"]
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectType == cat["name"]
                              ? const Color(0XFF8a4af3)
                              : Colors.black87,
                        ),
                      ),
                      selected: selectType == cat["name"],
                      selectedTileColor: const Color(0XFFECECF8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        setState(() {
                          selectType = cat["name"];
                          _searchQuery = '';
                          _searchController.clear();
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
              const Divider(thickness: 1, height: 0),
              Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.person_outline, color: Colors.black54),
                    title: const Text("Profile"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Profile()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.black54),
                    title: const Text("Sign In"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LogIn()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Available Jobs",
            style: TextStyle(color: Color(0XFF5d2ee6))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0XFF5d2ee6)),
        actions: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Favorite()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0XFFececf8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bookmark, color: Color(0XFF8a4af3)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _searchController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search for a job',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.trim()),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 5),
                width: 120,
                height: 30,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortOrder,
                    hint: const Text(
                      "Sort by",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF8a4af3)),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    items: ['Latest', 'Oldest']
                        .map((order) => DropdownMenuItem(
                              value: order,
                              child: Row(
                                children: [
                                  Icon(
                                    order == 'Latest'
                                        ? Icons.access_time
                                        : Icons.history_toggle_off,
                                    color: const Color(0xFF8a4af3),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(order),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value!;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: getFilteredProducts(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitWaveSpinner(
                          color: Color(0XFF8a4af3), size: 40),
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
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.sharedAxisVertical,
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
                                    postedDate: ds['timestamp'],
                                    vacancies: ds['vacancies'],
                                    favourite: const [],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: SizedBox(
                                      height: 180,
                                      width: double.infinity,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: ds["image"],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                    color: Colors.grey[200],
                                                    height: 180),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error,
                                                        size: 50),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                formatPostedDate(
                                                    ds['timestamp']),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(ds["name"],
                                            style: AppWidgets
                                                .boldTextFieldStyle()),
                                        const SizedBox(height: 15),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 18,
                                                color: Colors.black54),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Last Date: ${ds["price"]}",
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500),
                                            ),
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
                                                ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 220),
                                                  child: Text(
                                                    "Location: ${ds["location"]}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0XFF5d2ee6),
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.people,
                                                    size: 18,
                                                    color: Colors.black54),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Vacancies: ${ds["vacancies"]}",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0XFF5d2ee6),
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  )
                                ],
                              ),
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
