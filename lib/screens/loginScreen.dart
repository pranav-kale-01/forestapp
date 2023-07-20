// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/screens/User/homeUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/themeHelper.dart';
import 'Admin/homeAdmin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Key _formKey = GlobalKey<FormState>();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // String? _errorMessage;

  void loginAsAdmin() async {
    try {
      // Get the user document from Firestore based on the email entered
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email',
          isEqualTo: _emailController
              .text
              .trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query snapshot
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        // checking if user has proper privileges or not
        if (!userDoc.get('privileged_user')) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'User is an Admin'),
                content: const Text(
                    'This User does not have the privilege to login as an Admin.'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle any errors that occur during sign in
      if (e.code == 'user-not-found') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                  'User not found'),
              content: const Text(
                  'No user found for that email.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      else if (e.code == 'wrong-password') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                  'Wrong password'),
              content: const Text(
                  'Wrong password provided for that user.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

    // Authenticate the user with Firebase
    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
    ).then((value) async {
        await FirebaseAuth.instance.setPersistence(
            Persistence.LOCAL);
    }).catchError((error) {
        // handle error
    });

    // Get an instance of shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store the email in shared preferences
    prefs.setBool('isAdmin', true );
    prefs.setString('userEmail', _emailController.text.trim());

    // Navigate to the HomeAdmin screen on successful login
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const HomeAdmin( ),
        ),
      );
  }

  void loginAsUser() async {
    try {
      final userEmail = _emailController.text.trim();

      // Get the user document from Firestore based on the email entered
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail )
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query snapshot
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        // checking if user has proper privileges or not
        if( userDoc.get('privileged_user') ) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'User is an Admin'),
                content: const Text(
                    'The User you are trying to log in with is an Admin. Please Login using Admin to continue'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        // Compare the entered password with the password in Firestore
        if (userDoc.get('password') == _passwordController.text) {
          // Navigate to the HomeAdmin screen on successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
              HomeUser(
                  userEmail: userEmail,
              ),
            ),
          );
          // Get an instance of shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Store the email in shared preferences
          prefs.setString('userEmail', _emailController.text.trim());
        }
        else {
          // Show an alert dialog for wrong password
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'Wrong password'),
                content: const Text(
                    'Wrong password provided for that user.'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Show an alert dialog for user not found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                  'User not found'),
              content: const Text(
                  'No user found for that email.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e, s) {
      // Handle any errors that occur during sign in
      debugPrint( e.toString() );
      debugPrint( s.toString() );
    }
}

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SafeArea(
                child: Container(
                    padding: const EdgeInsets.fromLTRB( 20, 100, 20, 10),
                    margin: const EdgeInsets.fromLTRB( 10, 10, 10, 10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 130,
                          child: Image.asset('assets/splash_screen.jpg'),
                        ),

                        const SizedBox(
                          height: 90,
                        ),

                        Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  decoration:
                                      ThemeHelper().inputBoxDecorationShaddow(),
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: ThemeHelper()
                                        .textInputDecoration(
                                        'Email', 'Email'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Container(
                                  decoration:
                                      ThemeHelper().inputBoxDecorationShaddow(),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: ThemeHelper()
                                        .textInputDecoration(
                                            'Password', 'Password'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 20),
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigator.push( context, MaterialPageRoute( builder: (context) => ForgotPasswordPage()), );
                                    },
                                    child: const Text(
                                      "Forgot password",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 5, 0, 5
                                  ),
                                  width: mediaQuery.size.width,
                                  constraints: BoxConstraints(
                                    maxWidth: 350,
                                  ),
                                  decoration: ThemeHelper().buttonBoxDecoration(context),
                                  child: ElevatedButton(
                                    style: ThemeHelper().buttonStyle(),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      loginAsUser();
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    0, 5, 0, 5
                                  ),
                                  decoration: ThemeHelper().buttonBoxDecoration(context),
                                  width: mediaQuery.size.width,
                                  constraints: BoxConstraints(
                                    maxWidth: 350,
                                  ),
                                  child: ElevatedButton(
                                    style: ThemeHelper().buttonStyle(),
                                    child: const Text(
                                      'Login as admin',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      loginAsAdmin();
                                    },
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 20, 10, 20),
                                  //child: Text('Don\'t have an account? Create'),
                                ),
                              ],
                            )),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
