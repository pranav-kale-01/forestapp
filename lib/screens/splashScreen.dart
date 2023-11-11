import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forestapp/contstant/constant.dart';
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
  bool _isVisible = false;


  Future<Widget> check_user() async{
    final prefs = await SharedPreferences.getInstance();

    final user_type = prefs.getInt(SHARED_USER_TYPE) ?? noOne;

    if(user_type == admin){
      return HomeAdmin();
    }else if(user_type == user){
      var userEmail = prefs.getString(SHARED_USER_EMAIL);
      return HomeUser(userEmail: userEmail!);
    }else{
      return LoginScreen();
    }

  }

  _SplashScreenState() {
    Timer(const Duration(milliseconds: 3000), () {
      setState(() {
         check_user().then((screen) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => screen,
              ),
              (route) => false);
        });
      });

        
    });

    Timer(const Duration(milliseconds: 60), () {
      setState(() {
        _isVisible = true;
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
                  child: Image.asset('assets/splash_screen.png'),
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
                    child: Image.asset('assets/splash_screen.png', width: 26, height: 26),
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
