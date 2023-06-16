import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/ConflictModel.dart';
import 'package:forestapp/screens/Admin/EditTigerAdmin.dart';
import 'package:intl/intl.dart';

import '../User/ForestDataScreen.dart';
import '../User/ForestMapScreen.dart';


class ForestDetail extends StatelessWidget {
  final ConflictModel forestData;

  const ForestDetail({Key? key, required this.forestData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.white,
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
          'Forest Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              forestData.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: mediaQuery.size.height * 0.42,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      forestData.village_name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(forestData.userImage),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(forestData.userName),
                            Text(forestData.userEmail),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text( "Created At: " + DateFormat('MMM d, yyyy h:mm a').format(forestData.datetime!.toDate()),),
                    SizedBox(height: 16),
                    Text( 'Latitude: ${forestData.location.latitude}, Longitude: ${forestData.location.longitude}'),
                    SizedBox(height: 16),
                    Text('Range: ${forestData.range}'),
                    SizedBox(height: 16),
                    Text('Round: ${forestData.round}'),
                    SizedBox(height: 16),
                    Text('Bt: ${forestData.bt}'),
                    SizedBox(height: 16),
                    Text('C.No/S.No Name: ${forestData.cNoName}'),
                    SizedBox(height: 16),
                    Text('Conflict: ${forestData.conflict}'),
                    SizedBox(height: 16),
                    Text('Name: ${forestData.person_name}'),
                    SizedBox(height: 16),
                    Text('Age: ${forestData.person_age}'),
                    SizedBox(height: 16),
                    Text('Gender: ${forestData.person_gender}'),
                    SizedBox(height: 16),
                    Text('Sp Causing Death: ${forestData.sp_causing_death}'),
                    SizedBox(height: 16),
                    Text('Notes: ${forestData.notes}'),
                    SizedBox(height: 16),
                    Text('Guard Contact: ${forestData.userContact}'),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green.shade400, // Background color
                    // Text Color (Foreground color)
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ForestMapScreen(
                          latitude: forestData.location.latitude,
                          longitude: forestData.location.longitude,
                          userName: forestData.userName,
                          tigerName: forestData.village_name,
                        ),
                      ),
                    );
                  },
                  label: const Text("Show on Map"),
                  icon: const Icon(Icons.arrow_right_alt_outlined),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.red.shade400, // Background color
                    // Text Color (Foreground color)
                  ),
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
                            .collection('forestdata')
                            .where('user_email',
                            isEqualTo: forestData.userEmail)
                            .get();
                        if (snapshot.docs.isNotEmpty) {
                          await snapshot.docs.first.reference.delete();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const ForestDataScreen()),
                                  (route) => false);
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
                  child: Text("Delete"),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green.shade400, // Background color
                    // Text Color (Foreground color)
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditTigerAdmin(conflictData: forestData,))
                    );

                  },
                  child: const Text("Edit"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
