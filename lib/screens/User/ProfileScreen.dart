// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/user.dart';
import 'package:forestapp/contstant/constant.dart';
import 'package:forestapp/utils/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:forestapp/utils/utils.dart';
import '../loginScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _userEmail;
  User? _profileData;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString(SHARED_USER_EMAIL);
    setState(() {
      _userEmail = userEmail ?? '';
    });

    if( await hasConnection ) {
      _profileData = await UserService.getUser( context, _userEmail );
    }

    setState(() {});
  }


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
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.remove(SHARED_USER_EMAIL);
                            prefs.remove(SHARED_USER_LONGITUDE);
                            prefs.remove(SHARED_USER_LATITUDE);
                            prefs.remove(SHARED_USER_RADIUS);
                            prefs.remove(SHARED_USER_NAME);
                            prefs.remove(SHARED_USER_CONTACT);
                            prefs.remove(SHARED_USER_IMAGEURL);
                            prefs.setInt(SHARED_USER_TYPE, noOne );
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
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if( snapshot.connectionState == ConnectionState.waiting ) {
            return const Center(child: CircularProgressIndicator());
          }
          else {
            return Center(
              child: _profileData == null ? Center(
                child: Text("Unable to Load profile Data"),
              ): Column(
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
                          image: NetworkImage(
                            '${baseUrl}uploads/guard/profile/${_profileData!.imageUrl}',
                          ),
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
                      "Email : " + _profileData!.email,
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
                          _profileData!.forestId.toString(),
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
                          _profileData!.longitude.toString(),
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
                          _profileData!.latitude.toString(),
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
                          (  ( _profileData!.radius).round() ).toString() + "Km",
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    const Spacer(),
                  ]),
            );
          }
        },
      ),
    );
  }
}
