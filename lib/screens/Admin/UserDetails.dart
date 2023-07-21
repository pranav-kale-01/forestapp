import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/user.dart';

class UserDetails extends StatelessWidget {
  final User user;
  const UserDetails({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Edit User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 30,
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(user.imageUrl),
                fit: BoxFit.cover,
              ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 16),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adhar Number: ${user.aadharNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Forest ID: ${user.forestId.toString()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contact Number: ${user.contactNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: ${user.email}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Longitude:${user.longitude}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Latitude:${user.latitude}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Radius range:${user.radius}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),

                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                  'Are you sure you want to delete this user?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              final snapshot = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('email', isEqualTo: user.email)
                                  .get();
                              if (snapshot.docs.isNotEmpty) {
                                // first deleting the image
                                // first deleting the images
                                Reference storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child('user-images')
                                    .child("${user.forestId.toString()}/${user.forestId.toString()}.jpg");

                                await storageRef.delete();

                                storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child('user-images')
                                    .child("${user.forestId.toString()}/${user.forestId.toString()}_aadhar.jpg");

                                await storageRef.delete();

                                storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child('user-images')
                                    .child("${user.forestId.toString()}/${user.forestId.toString()}_forestID.jpg");

                                await storageRef.delete();


                                // now deleting the record from Firestore database
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
