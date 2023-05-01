import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<User> users = [
    User(
      name: 'John Doe',
      email: 'johndoe@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    User(
      name: 'Jane Smith',
      email: 'janesmith@example.com',
      profileImage: 'https://randomuser.me/api/portraits/women/1.jpg',
    ),
    User(
      name: 'Bob Johnson',
      email: 'bobjohnson@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/2.jpg',
    ),
    User(
      name: 'John Doe',
      email: 'johndoe@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    User(
      name: 'Jane Smith',
      email: 'janesmith@example.com',
      profileImage: 'https://randomuser.me/api/portraits/women/1.jpg',
    ),
    User(
      name: 'Bob Johnson',
      email: 'bobjohnson@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/2.jpg',
    ),

    User(
      name: 'John Doe',
      email: 'johndoe@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    User(
      name: 'Jane Smith',
      email: 'janesmith@example.com',
      profileImage: 'https://randomuser.me/api/portraits/women/1.jpg',
    ),
    User(
      name: 'Bob Johnson',
      email: 'bobjohnson@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/2.jpg',
    ),
    User(
      name: 'John Doe',
      email: 'johndoe@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    User(
      name: 'Jane Smith',
      email: 'janesmith@example.com',
      profileImage: 'https://randomuser.me/api/portraits/women/1.jpg',
    ),
    User(
      name: 'Bob Johnson',
      email: 'bobjohnson@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/2.jpg',
    ),
    User(
      name: 'John Doe',
      email: 'johndoe@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    User(
      name: 'Jane Smith',
      email: 'janesmith@example.com',
      profileImage: 'https://randomuser.me/api/portraits/women/1.jpg',
    ),
    User(
      name: 'Bob Johnson',
      email: 'bobjohnson@example.com',
      profileImage: 'https://randomuser.me/api/portraits/men/2.jpg',
    ),
    // Add more users as needed
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Users',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    User user = users[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user.profileImage),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(user.email),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Implement edit user functionality
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // TODO: Implement delete user functionality
                              },
                            ),
                          ],
                        ),
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

class User {
  final String name;
  final String email;
  final String profileImage;

  User({required this.name, required this.email, required this.profileImage});
}
