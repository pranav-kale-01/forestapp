import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../loginScreen.dart';
import 'ForestDataScreen.dart';

class ProfileData {
  final String title;
  final String description;
  final String imageUrl;
  final String userName;
  final String userEmail;
  final Timestamp? datetime;

  ProfileData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.userEmail,
    this.datetime,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _userEmail;
  late List<ProfileData> _profileDataList = [];

  int _userProfileDataCount = 0;

  int? _count;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    getTotalDocumentsCount().then((value) {
      setState(() {
        _count = value;
      });
    });
    getTotalDocumentsCountUser().then((value) {});
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    setState(() {
      _userEmail = userEmail ?? '';
    });
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('forestdata')
        .where('user_email', isEqualTo: _userEmail)
        // .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    final profileDataList = userSnapshot.docs
        .map((doc) => ProfileData(
              imageUrl: doc['imageUrl'],
              title: doc['title'],
              description: doc['description'],
              userName: doc['user_name'],
              userEmail: doc['user_email'],
              datetime: doc['createdAt'] as Timestamp?,
            ))
        .toList();
    setState(() {
      _profileDataList = profileDataList;
      _userProfileDataCount = userSnapshot.size;
    });
  }

  Future<int> getTotalDocumentsCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('forestdata')
        // .where('user_email', isEqualTo: _userEmail)
        // .orderBy('createdAt', descending: true)
        .get();
    return snapshot.size;
  }

  Future<int> getTotalDocumentsCountUser() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  // late final int numberOfTigers;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    if (_profileDataList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          flexibleSpace: Container(
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )),
          title: const Text('Pench MH'),
          actions: [
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content:
                            const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove('userEmail');
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      // perform logout
                    }
                  },
                ),
                // const Text("Logout"),
              ],
            ),
          ],
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No Data Found.....",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 5,
              ),
              CircularProgressIndicator()
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        flexibleSpace: Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )),
        title: const Text('Pench MH'),
        actions: [
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.remove('userEmail');
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    // perform logout
                  }
                },
              ),
              // const Text("Logout"),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const ForestDataScreen()),
                      (route) => false);
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Total Tigers Entries',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        const Icon(
                          Icons.trending_up,
                          size: 50.0,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          '$_userProfileDataCount',
                          style: TextStyle(fontSize: 24.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Recent Entries",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 16.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade500),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Tiger Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'User Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Date & Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'View',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _profileDataList.map((profileData) {
                      return DataRow(
                        cells: [
                          DataCell(Text(profileData.title)),
                          DataCell(Text(profileData.userName)),
                          DataCell(Text(DateFormat('dd/MM/yyyy hh:mm')
                              .format(profileData.datetime!.toDate()))),
                          DataCell(IconButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => ForestDataScreen()),
                                  (route) => false);
                            },
                            icon: Icon(Icons.visibility),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
