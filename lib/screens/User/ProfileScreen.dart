// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:forestapp/utils/utils.dart';
import '../loginScreen.dart';

class ProfileData {
  final String name;
  final String email;
  final String contactNumber;
  final String imageUrl;
  final String aadharNumber;
  final String forestId;
  final String longitude;
  final String latitude;
  final String radius;
  // final int numberOfForestsAdded;

  ProfileData({
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.imageUrl,
    required this.aadharNumber,
    required this.forestId,
    required this.longitude,
    required this.latitude,
    required this.radius,
    // required this.numberOfForestsAdded,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _userEmail;
  ProfileData? _profileData;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
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
        .collection('users')
        .where('email', isEqualTo: _userEmail)
        .get();
    final userData = userSnapshot.docs.first.data();
    setState(() {
      _profileData = ProfileData(
        name: userData['name'],
        email: userData['email'],
        contactNumber: userData['contactNumber'],
        imageUrl: userData['imageUrl'],
        aadharNumber: userData['aadharNumber'],
        forestId: userData['forestID'],
        longitude: userData['location'].longitude.toString(),
        latitude: userData['location'].latitude.toString(),
        radius: userData['radius'].toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_profileData == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
          'Pench MH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
                            Util.hasUserLocation = false;
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 100,
              ),
              Container(
                width: 150.0,
                height: 150.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(_profileData!.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                _profileData!.name,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _profileData!.email,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Contact Number: "),
                  Text(
                    _profileData!.contactNumber,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Aadhar Number: "),
                  Text(
                    _profileData!.aadharNumber,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Forest ID: "),
                  Text(
                    _profileData!.forestId,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Longitude: "),
                  Text(
                    _profileData!.longitude,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Latitude: "),
                  Text(
                    _profileData!.latitude,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Radius Area: "),
                  Text(
                    _profileData!.radius,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              const Spacer(),
            ]),
      ),
    );
  }
}
