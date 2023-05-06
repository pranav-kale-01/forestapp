import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/screens/Admin/EditUserScreen.dart';
import 'package:forestapp/screens/Admin/UserDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../loginScreen.dart';
import 'homeAdmin.dart';

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

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late String _userEmail;
  late List<ProfileData> _profileDataList = [];
  late List<ProfileData> _searchResult = [];

  final TextEditingController _searchController = TextEditingController();

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
      _searchResult = profileDataList;
    });
  }

  void _filterList(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      List<ProfileData> tempList = [];
      _profileDataList.forEach((profileData) {
        if (profileData.userName
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            profileData.userEmail
                .toLowerCase()
                .contains(searchQuery.toLowerCase())) {
          tempList.add(profileData);
        }
      });
      setState(() {
        _searchResult = tempList;
      });
      return;
    } else {
      setState(() {
        _searchResult = _profileDataList;
      });
    }
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

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    // if (_profileDataList.isEmpty) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0), // hide the app bar
        child: AppBar(
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
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const HomeAdmin(
                                  title: '',
                                )),
                        (route) => false);
                  },
                ),
                Center(
                  child: Text(
                    'Guard',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: TextField(
            //     controller: _searchController,
            //     decoration: InputDecoration(
            //       labelText: 'Search',
            //       hintText: 'Search by title, user name or user email',
            //       prefixIcon: const Icon(Icons.search),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     onChanged: (value) {
            //       _filterList(value);
            //     },
            //   ),
            // ),
            _searchResult.isEmpty
                ? Text(
                    "No result found....",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  )
                : Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: users.snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data =
                                documents[index].data() as Map<String, dynamic>;

                            return InkWell(
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => UserDetails(
                                              user: data,
                                            )),
                                    (route) => false);
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            data['imageUrl'] as String),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['name'] as String,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(data['email'] as String),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditUserScreen(
                                                            user: data,
                                                          )),
                                                  (route) => false);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          final confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  'Confirm Deletion'),
                                              content: const Text(
                                                  'Are you sure you want to delete this user?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              final snapshot =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .where('email',
                                                          isEqualTo:
                                                              data['email'])
                                                      .get();
                                              if (snapshot.docs.isNotEmpty) {
                                                await snapshot
                                                    .docs.first.reference
                                                    .delete();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'User deleted successfully.'),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content:
                                                        Text('User not found.'),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error deleting user: $e'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
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
