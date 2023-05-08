import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ForestDataScreen.dart';

class ForestDetail extends StatelessWidget {
  final ProfileData forestData;

  const ForestDetail({Key? key, required this.forestData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: Text(forestData.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const ForestDataScreen()),
                (route) => false);
          },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forestData.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(forestData.description),
                SizedBox(height: 8),
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
                SizedBox(height: 8),
                Text(
                  DateFormat('MMM d, yyyy h:mm a')
                      .format(forestData.datetime!.toDate()),
                ),
                SizedBox(height: 8),
                Text(
                    'Latitude: ${forestData.location.latitude}, Longitude: ${forestData.location.longitude}'),

                SizedBox(height: 8),
                Text('Number Of Cubs: ${forestData.noOfCubs}'),
                SizedBox(height: 8),
                Text('Number Of Tigers: ${forestData.noOfTigers}'),
                SizedBox(height: 8),
                Text('Remark: ${forestData.remark}'),
                SizedBox(height: 8),
                Text('Guard Contact: ${forestData.userContact}'),
                SizedBox(height: 16),

                Row(
                  children: [
                    ElevatedButton(
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
                  ],
                ),
                SizedBox(height: 16),
                // Expanded(
                //   child: WebViewWidget(
                //       controller: WebViewController()
                //         ..loadRequest(
                //           Uri.parse(
                //               'https://www.google.com/maps/search/?api=1&query=${forestData.location.latitude.toString()},${forestData.location.longitude.toString()}'),
                //         )
                //         ..setJavaScriptMode(JavaScriptMode.unrestricted)),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
