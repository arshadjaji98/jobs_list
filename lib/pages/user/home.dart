// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:groceryease_delivery_application/pages/registration/signup.dart';
import 'package:groceryease_delivery_application/pages/user/details.dart';
import 'package:groceryease_delivery_application/pages/user/category_jobs.dart';
import 'package:groceryease_delivery_application/pages/user/favorite.dart';
import 'package:groceryease_delivery_application/pages/user/profile.dart';
import 'package:groceryease_delivery_application/pages/user/announcements.dart';
import 'package:groceryease_delivery_application/widgets/widget_support.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:groceryease_delivery_application/services/theme_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:groceryease_delivery_application/services/local_database_service.dart';
import 'dart:async';

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

  String? selectedLocation;
  double? minSalary;
  double? maxSalary;
  String? selectedJobType;
  String? selectedExperienceLevel;

  List<Map<String, dynamic>> categories = [
    {"name": "Forces Jobs", "icon": Icons.security},
    {"name": "Govt Jobs", "icon": Icons.account_balance},
    {"name": "Private Jobs", "icon": Icons.business_center},
    {"name": "Semi-Govt Jobs", "icon": Icons.apartment},
    {"name": "Others", "icon": Icons.more_horiz},
  ];

  String? selectType;
  String _sortOrder = 'Latest';

  Connectivity _connectivity = Connectivity();
  List<Map<String, dynamic>> _jobs = [];
  bool _isOnline = true;
  StreamSubscription? _subscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsername();
    _connectivity.onConnectivityChanged.listen((result) {
      bool wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      if (!wasOnline && _isOnline) {
        _loadData();
      }
    });
    _loadData();
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
    _subscription?.cancel();
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
      if (kDebugMode) {
        print('Error fetching username: $e');
      }
    }
  }

  Future<void> _loadData() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    if (_isOnline) {
      _jobs = await LocalDatabaseService().getJobs(); // load cached first
      _isLoading = false;
      setState(() {});
      // then listen to stream
      _subscription = getFilteredProducts().listen((snapshot) {
        _jobs = snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList();
        LocalDatabaseService().insertJobs(_jobs);
        _isLoading = false;
        setState(() {});
      });
    } else {
      _jobs = await LocalDatabaseService().getJobs();
      _isLoading = false;
      setState(() {});
    }
  }

  Stream<QuerySnapshot> getFilteredProducts() {
    Query collection = FirebaseFirestore.instance.collection("products");

    if (selectType != null) {
      collection = collection.where("type", isEqualTo: selectType);
    }
    if (selectedJobType != null && selectedJobType != selectType) {
      collection = collection.where("type", isEqualTo: selectedJobType);
    }
    if (selectedLocation != null) {
      collection = collection.where("location", isEqualTo: selectedLocation);
    }

    return collection.snapshots().handleError((error) {
      if (kDebugMode) {
        print('Firestore query error: $error');
      }
      return const Stream.empty();
    });
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Filters",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedLocation,
                    decoration: const InputDecoration(labelText: "Location"),
                    items: [
                      "Islamabad",
                      "Lahore",
                      "Karachi",
                      "Peshawar",
                      "Quetta"
                    ]
                        .map((loc) =>
                            DropdownMenuItem(value: loc, child: Text(loc)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedLocation = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: minSalary?.toString(),
                          decoration:
                              const InputDecoration(labelText: "Min Salary"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              minSalary = double.tryParse(value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: maxSalary?.toString(),
                          decoration:
                              const InputDecoration(labelText: "Max Salary"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              maxSalary = double.tryParse(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedJobType,
                    decoration: const InputDecoration(labelText: "Job Type"),
                    items: [
                      "Forces Jobs",
                      "Govt Jobs",
                      "Private Jobs",
                      "Semi-Govt Jobs",
                      "Others"
                    ]
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedJobType = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedExperienceLevel,
                    decoration:
                        const InputDecoration(labelText: "Experience Level"),
                    items: ["Entry Level", "Mid Level", "Senior Level"]
                        .map((exp) =>
                            DropdownMenuItem(value: exp, child: Text(exp)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedExperienceLevel = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedLocation = null;
                            minSalary = null;
                            maxSalary = null;
                            selectedJobType = null;
                            selectedExperienceLevel = null;
                          });
                          Navigator.pop(context);
                          this.setState(() {});
                        },
                        child: const Text("Clear All"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          this.setState(() {});
                        },
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobList() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 150,
                      color: Theme.of(context).colorScheme.surfaceVariant),
                  const SizedBox(height: 12),
                  Container(
                      height: 16,
                      width: 200,
                      color: Theme.of(context).colorScheme.surfaceVariant),
                  const SizedBox(height: 8),
                  Container(
                      height: 14,
                      width: 120,
                      color: Theme.of(context).colorScheme.surfaceVariant),
                ],
              ),
            ),
          );
        },
      );
    }
    // apply filters
    var filteredJobs = _jobs.where((job) {
      if (selectType != null && job['type'] != selectType) return false;
      if (selectedJobType != null &&
          selectedJobType != selectType &&
          job['type'] != selectedJobType) return false;
      if (selectedLocation != null && job['location'] != selectedLocation)
        return false;
      if (_searchQuery.isNotEmpty) {
        final jobName = (job['name'] ?? '').toString().toLowerCase();
        final jobDetail = (job['detail'] ?? '').toString().toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        if (!jobName.contains(searchLower) && !jobDetail.contains(searchLower))
          return false;
      }
      double price = double.tryParse(job['price'].toString()) ?? 0.0;
      if (minSalary != null && price < minSalary!) return false;
      if (maxSalary != null && price > maxSalary!) return false;
      if (selectedExperienceLevel != null &&
          job['experience'] != selectedExperienceLevel) return false;
      // sort order
      if (_sortOrder == 'This Week' || _sortOrder == 'This Month') {
        final ts = job['timestamp'];
        if (ts is Timestamp) {
          DateTime date = ts.toDate();
          DateTime now = DateTime.now();
          if (_sortOrder == 'This Week') {
            DateTime startOfWeek =
                now.subtract(Duration(days: now.weekday - 1));
            if (!(date.isAfter(startOfWeek.subtract(const Duration(days: 1))) ||
                date.isAtSameMomentAs(startOfWeek))) return false;
          } else if (_sortOrder == 'This Month') {
            DateTime startOfMonth = DateTime(now.year, now.month, 1);
            if (!(date
                    .isAfter(startOfMonth.subtract(const Duration(days: 1))) ||
                date.isAtSameMomentAs(startOfMonth))) return false;
          }
        } else {
          return false;
        }
      }
      return true;
    }).toList();
    // sort
    filteredJobs.sort((a, b) {
      final timeA = a['timestamp'] as Timestamp?;
      final timeB = b['timestamp'] as Timestamp?;
      if (timeA == null || timeB == null) return 0;
      final comparison = timeB.compareTo(timeA);
      return _sortOrder == 'Oldest' ? -comparison : comparison;
    });
    if (filteredJobs.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? "No current job available"
              : "No job found for '$_searchQuery'",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _isOnline
          ? () async {
              // refresh from Firestore
              var snapshot =
                  await FirebaseFirestore.instance.collection("products").get();
              _jobs = snapshot.docs
                  .map((doc) => {...doc.data(), 'id': doc.id})
                  .toList();
              await LocalDatabaseService().insertJobs(_jobs);
              setState(() {});
            }
          : () async {},
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: filteredJobs.length,
        itemBuilder: (context, index) {
          var job = filteredJobs[index];
          bool isNew = false;
          if (job['timestamp'] != null && job['timestamp'] is Timestamp) {
            final postedDate = (job['timestamp'] as Timestamp).toDate();
            isNew = DateTime.now().difference(postedDate).inDays <= 3;
          }
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
                        image: job['image'],
                        name: job['name'],
                        details: job['detail'],
                        price: job['price'].toString(),
                        id: job['id'],
                        stock: job['quantity'].toString(),
                        adminId: job['adminId'],
                        type: job['type'],
                        location: job['location'],
                        postedDate: job['timestamp'],
                        vacancies: job['vacancies'],
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
                                imageUrl: job["image"],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  height: 180,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error, size: 50),
                              ),
                              if (isNew)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "NEW",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job["name"],
                                style: AppWidgets.boldTextFieldStyle(context)),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 18,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color),
                                const SizedBox(width: 6),
                                Text(
                                  "Last Date: ${job["price"]}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color),
                                    const SizedBox(width: 4),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 220),
                                      child: Text(
                                        "Location: ${job["location"]}",
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.people,
                                        size: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Vacancies: ${job["vacancies"]}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.w500,
                                          ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: SafeArea(
        child: Drawer(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.onPrimary),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/logo.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        FirebaseAuth.instance.currentUser != null
                            ? 'Hello, ${username ?? 'User'}'
                            : 'Welcome, Guest',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
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
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.8),
                ),
                title: Text(
                  "All Jobs",
                  style: TextStyle(
                    fontWeight: selectType == null
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectType == null
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.8),
                  ),
                ),
                selected: selectType == null,
                selectedTileColor: const Color(0XFFa970f5),
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
              ListTile(
                leading: Icon(Icons.announcement,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.8)),
                title: Text(
                  'Announcements',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.8)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Announcements(),
                    ),
                  );
                },
              ),
              Divider(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.4)),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: categories.map((cat) {
                    bool isSelected = selectType == cat["name"];

                    return ListTile(
                      leading: Icon(
                        cat["icon"],
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.8),
                      ),
                      title: Text(
                        cat["name"],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withOpacity(0.8),
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryJobsScreen(category: cat["name"]),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              Divider(
                  thickness: 1,
                  height: 0,
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.4)),
              Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeService.modeNotifier,
                    builder: (context, mode, _) {
                      return ListTile(
                        leading: Icon(Icons.dark_mode,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.8)),
                        title: Text(
                          "Dark Mode",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withOpacity(0.8)),
                        ),
                        trailing: Switch.adaptive(
                          value: ThemeService.isDark,
                          activeColor: Theme.of(context).colorScheme.onPrimary,
                          onChanged: (v) => ThemeService.setDark(v),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person_outline,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.8)),
                    title: Text(
                      "Profile",
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.8)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Profile(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.login,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.8)),
                    title: Text(
                      "Create/Login",
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.8)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUp(),
                        ),
                      );
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
        title: Text("Available Jobs",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        actions: [
          InkWell(
            onTap: () => _showFilterModal(context),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.filter_list,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Favorite()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.bookmark,
                  color: Theme.of(context).colorScheme.primary),
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
                  borderRadius: BorderRadius.circular(12)),
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
                width: 160,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortOrder,
                    hint: Text(
                      "Sort by",
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.primary,
                      size: 25,
                    ),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    style: Theme.of(context).textTheme.bodyLarge,
                    items: ['Latest', 'Oldest', 'This Week', 'This Month']
                        .map((order) => DropdownMenuItem(
                              value: order,
                              child: Row(
                                children: [
                                  Icon(
                                    order == 'Latest'
                                        ? Icons.access_time
                                        : order == 'Oldest'
                                            ? Icons.history_toggle_off
                                            : order == 'This Week'
                                                ? Icons.calendar_view_week
                                                : Icons.calendar_view_month,
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
            Expanded(child: _buildJobList()),
          ],
        ),
      ),
    );
  }
}
