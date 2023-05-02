import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../loginScreen.dart';

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

  late int _count;
  late int _countUser;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    getTotalDocumentsCount().then((value) {
      setState(() {
        _count = value;
      });
    });
    getTotalDocumentsCountUser().then((value) {
      setState(() {
        _countUser = value;
      });
    });
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
        .orderBy('createdAt', descending: true)
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
    });
  }

  Future<int> getTotalDocumentsCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('forestdata').get();
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
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pench MH',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                  'Are you sure you want to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    // ignore: use_build_context_synchronously
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()),
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
                      const Text("Logout"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.animation,
                              size: 50,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No of tigers',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$_count',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.security,
                              size: 50,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No of guards',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$_countUser',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
              Expanded(
                child: ListView.builder(
                  itemCount: _profileDataList.length,
                  itemBuilder: (context, index) {
                    final profileData = _profileDataList[index];
                    return Card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        profileData.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        DateFormat('MMM d, yyyy h:mm a').format(
                                            profileData.datetime!.toDate()),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8.0),
                                          Text(
                                            profileData.userName,
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            profileData.userEmail,
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: const Text("View"))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
