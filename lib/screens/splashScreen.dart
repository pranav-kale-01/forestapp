import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/screens/Admin/homeAdmin.dart';
import 'package:forestapp/screens/User/homeUser.dart';
import 'package:forestapp/screens/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userEmail;
  bool _isVisible = false;
  bool _isAdmin = false;

  @override
  void initState() {
    fetchUserEmail();
    super.initState();
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    if( prefs.getBool('isAdmin') != null ) {
      _isAdmin = prefs.getBool('isAdmin')!;
    }

    setState(() {
      _userEmail = userEmail;
    });
  }

  _SplashScreenState() {
    Timer(const Duration(milliseconds: 3000), () {
      setState(() {
        if (_isAdmin) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeAdmin(),
              ),
              (route) => false);
        } else if (_userEmail != null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeUser(
                  userEmail: _userEmail!,
                ),
              ),
              (route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false);
        }
      });
    });

    Timer(const Duration(milliseconds: 30), () {
      setState(() {
        _isVisible =
            true; // Now it is showing fade effect and navigating to Login page
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white,
          ],
          begin: const FractionalOffset(0, 0),
          end: const FractionalOffset(1.0, 0.0),
          stops: const [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0,
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset('assets/splash_screen.jpg'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Image.asset(
                    'assets/flag.png',
                    width: 20,
                    height: 20
                   ),
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Icon(Icons.favorite, color: Colors.redAccent),
                  ),
                  SizedBox(
                  width: 2,
                  height: 2,
                  
                ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    width: 20,
                    height: 20,
                    child: Image.asset('assets/splash_screen.jpg', width: 26, height: 26),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
