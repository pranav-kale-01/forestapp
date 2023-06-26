import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:forestapp/screens/Admin/AddUserScreen.dart';
import 'package:forestapp/screens/Admin/EditUserScreen.dart';
import 'package:forestapp/screens/Admin/UserDetails.dart';
import '../../common/models/UserModel.dart';

class UserScreen extends StatefulWidget {
  final Function(int) changeIndex;

  const UserScreen({
    super.key,
    required this.changeIndex,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late List<UserModel> _searchResult = [];

  @override
  void initState() {
    super.initState();
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where( 'privileged_user', isEqualTo: false )
        .get();

    print( userSnapshot.size );

    final profileDataList = userSnapshot.docs
        .map((doc) => UserModel(
              imageUrl: doc['imageUrl'],
              password: doc['password'],
              email: doc['email'],
              name: doc['name'],
              aadharImageUrl: doc['aadharImageUrl'],
              forestID: doc['forestID'],
              contactNumber: doc['contactNumber'],
              forestIDImageUrl: doc['forestIDImageUrl'],
              aadharNumber: doc['aadharNumber'],
            ))
        .toList();

    setState(() {
      _searchResult = profileDataList;
    });

    print( _searchResult.first.toString() );
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

  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          height: 120,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              )
          ),
        ),
        title: const Text(
          'Guard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric( horizontal: 12.0),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => AddUserScreen(
                          changeIndex: widget.changeIndex,
                        ),
                    )
                  );
                },
                icon: Icon(
                  Icons.add
                ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: users.snapshots(),
                builder: (streamContext,snapshot) {
                  if( snapshot.hasData ) {
                    if ( _searchResult.isEmpty) {
                      return Center(
                        child: Text(
                          "No result found....",
                        ),
                      );
                    }
                    else {
                      final List<DocumentSnapshot> documents = snapshot.data!.docs;

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: documents.length,
                        itemBuilder: (innerContext, index) {
                          final data = documents[index].data() as Map<String, dynamic>;

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => UserDetails(
                                        user: data,
                                      )
                                  ),
                              );
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
                                        Navigator.of(innerContext).push(
                                          MaterialPageRoute(
                                            builder: (innerContext) =>
                                                EditUserScreen(
                                                  user: data,
                                                  changeIndex: widget.changeIndex,
                                                )
                                          ),
                                        );
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
                                            final snapshot = await FirebaseFirestore.instance
                                                .collection('users')
                                                .where('email', isEqualTo: data['email'])
                                                .get();

                                            if (snapshot.docs.isNotEmpty) {
                                              // first deleting the images
                                              Reference storageRef = FirebaseStorage.instance
                                                  .ref()
                                                  .child('user-images')
                                                  .child("${data['forestID']}/${data['forestID']}.jpg");

                                              await storageRef.delete();

                                              storageRef = FirebaseStorage.instance
                                                  .ref()
                                                  .child('user-images')
                                                  .child("${data['forestID']}/${data['forestID']}_aadhar.jpg");

                                              await storageRef.delete();

                                              storageRef = FirebaseStorage.instance
                                                  .ref()
                                                  .child('user-images')
                                                  .child("${data['forestID']}/${data['forestID']}_forestID.jpg");

                                              await storageRef.delete();

                                              // now deleting the record from firestore database
                                              await snapshot.docs.first.reference.delete();

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('User deleted successfully.'),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('User not found.'),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error deleting user: $e'),
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
                    }
                  }
                  else {
                    return const Center(
                        child: CircularProgressIndicator()
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
