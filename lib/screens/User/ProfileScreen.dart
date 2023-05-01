import 'package:flutter/material.dart';

class ProfileData {
  final String name;
  final String email;
  final String contactNumber;
  final int numberOfForestsAdded;

  ProfileData({
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.numberOfForestsAdded,
  });
}

class ProfileScreen extends StatelessWidget {
  final ProfileData profileData = ProfileData(
    name: 'John Doe',
    email: 'johndoe@example.com',
    contactNumber: '+1 555-555-5555',
    numberOfForestsAdded: 10,
  );

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Center(
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                      'https://randomuser.me/api/portraits/men/1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              profileData.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              profileData.email,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              profileData.contactNumber,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Number of Forests Added: ${profileData.numberOfForestsAdded}',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 100.0,
                height: 40.0,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
