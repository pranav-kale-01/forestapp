import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../loginScreen.dart';

class HomeScreen extends StatelessWidget {
  // late final int numberOfTigers;
  // late final int numberOfGuards;

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
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
                          children: const [
                            Icon(
                              Icons.animation,
                              size: 50,
                              color: Colors.orange,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No of tigers',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "10",
                              style: TextStyle(
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
                          children: const [
                            Icon(
                              Icons.security,
                              size: 50,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No of guards',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '20',
                              style: TextStyle(
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
              const Expanded(
                child: Text("Recent Data"),
                //   child: StreamBuilder<QuerySnapshot>(
                //     stream: users.snapshots(),
                //     builder: (BuildContext context,
                //         AsyncSnapshot<QuerySnapshot> snapshot) {
                //       if (!snapshot.hasData) {
                //         return const Center(child: CircularProgressIndicator());
                //       }

                //       final List<DocumentSnapshot> documents =
                //           snapshot.data!.docs;
                //       return ListView.builder(
                //         itemCount: documents.length,
                //         itemBuilder: (BuildContext context, int index) {
                //           final data =
                //               documents[index].data() as Map<String, dynamic>;

                //           return Card(
                //             child: Padding(
                //               padding: const EdgeInsets.all(16.0),
                //               child: Row(
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   CircleAvatar(
                //                     backgroundImage:
                //                         NetworkImage(data['imageUrl'] as String),
                //                   ),
                //                   const SizedBox(width: 16.0),
                //                   Expanded(
                //                     child: Column(
                //                       crossAxisAlignment:
                //                           CrossAxisAlignment.start,
                //                       children: [
                //                         Text(
                //                           data['name'] as String,
                //                           style: const TextStyle(
                //                             fontWeight: FontWeight.bold,
                //                             fontSize: 20.0,
                //                           ),
                //                         ),
                //                         const SizedBox(height: 8.0),
                //                         Text(data['email'] as String),
                //                       ],
                //                     ),
                //                   ),
                //                   const SizedBox(width: 16.0),
                //                   IconButton(
                //                     icon: const Icon(Icons.edit),
                //                     onPressed: () {},
                //                   ),
                //                   IconButton(
                //                     icon: const Icon(Icons.delete),
                //                     onPressed: () async {
                //                       final confirm = await showDialog(
                //                         context: context,
                //                         builder: (context) => AlertDialog(
                //                           title: const Text('Confirm Deletion'),
                //                           content: const Text(
                //                               'Are you sure you want to delete this user?'),
                //                           actions: [
                //                             TextButton(
                //                               onPressed: () =>
                //                                   Navigator.pop(context, false),
                //                               child: const Text('Cancel'),
                //                             ),
                //                             TextButton(
                //                               onPressed: () =>
                //                                   Navigator.pop(context, true),
                //                               child: const Text('Delete'),
                //                             ),
                //                           ],
                //                         ),
                //                       );
                //                       if (confirm == true) {
                //                         try {
                //                           final snapshot = await FirebaseFirestore
                //                               .instance
                //                               .collection('users')
                //                               .where('email',
                //                                   isEqualTo: data['email'])
                //                               .get();
                //                           if (snapshot.docs.isNotEmpty) {
                //                             await snapshot.docs.first.reference
                //                                 .delete();
                //                             ScaffoldMessenger.of(context)
                //                                 .showSnackBar(
                //                               const SnackBar(
                //                                 content: Text(
                //                                     'User deleted successfully.'),
                //                               ),
                //                             );
                //                           } else {
                //                             ScaffoldMessenger.of(context)
                //                                 .showSnackBar(
                //                               const SnackBar(
                //                                 content: Text('User not found.'),
                //                               ),
                //                             );
                //                           }
                //                         } catch (e) {
                //                           ScaffoldMessenger.of(context)
                //                               .showSnackBar(
                //                             SnackBar(
                //                               content:
                //                                   Text('Error deleting user: $e'),
                //                             ),
                //                           );
                //                         }
                //                       }
                //                     },
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           );
                //         },
                //       );
                //     },
                //   ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
