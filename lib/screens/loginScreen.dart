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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SafeArea(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 200, 20, 10),
                    margin: const EdgeInsets.fromLTRB(
                        20, 10, 20, 10), // This will be the login form
                    child: Column(
                      children: [
                        const Text(
                          'Login into your account',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30.0),
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
                                            'Email', 'Enter your user name'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30.0),
                                Container(
                                  decoration:
                                      ThemeHelper().inputBoxDecorationShaddow(),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: ThemeHelper()
                                        .textInputDecoration(
                                            'Password', 'Enter your password'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 20),
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigator.push( context, MaterialPageRoute( builder: (context) => ForgotPasswordPage()), );
                                    },
                                    child: const Text(
                                      "Forgot your password?",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: ThemeHelper()
                                      .buttonBoxDecoration(context),
                                  child: ElevatedButton(
                                    style: ThemeHelper().buttonStyle(),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          40, 10, 40, 10),
                                      child: Text(
                                        'Sign In As Admin'.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        // Authenticate the user with Firebase
                                        UserCredential userCredential =
                                            await FirebaseAuth.instance
                                                .signInWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        );
                                        FirebaseAuth.instance
                                            .signInWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        )
                                            .then((value) async {
                                          await FirebaseAuth.instance
                                              .setPersistence(
                                                  Persistence.LOCAL);
                                          // user is now signed in and persistence is enabled
                                        }).catchError((error) {
                                          // handle error
                                        });

                                        // Navigate to the HomeAdmin screen on successful login
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeAdmin(title: 'hello'),
                                          ),
                                        );
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
                                        } else if (e.code == 'wrong-password') {
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
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  decoration: ThemeHelper()
                                      .buttonBoxDecoration(context),
                                  child: ElevatedButton(
                                    style: ThemeHelper().buttonStyle(),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          40, 10, 40, 10),
                                      child: Text(
                                        'Sign In As User'.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        // Get the user document from Firestore based on the email entered
                                        QuerySnapshot querySnapshot =
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .where('email',
                                                    isEqualTo: _emailController
                                                        .text
                                                        .trim())
                                                .get();

                                        if (querySnapshot.docs.isNotEmpty) {
                                          // Get the first document from the query snapshot
                                          DocumentSnapshot userDoc =
                                              querySnapshot.docs.first;

                                          // Compare the entered password with the password in Firestore
                                          if (userDoc.get('password') ==
                                              _passwordController.text) {
                                            // Navigate to the HomeAdmin screen on successful login
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeUser(
                                                        title: 'hello'),
                                              ),
                                            );
                                            // Get an instance of shared preferences
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();

// Store the email in shared preferences
                                            prefs.setString('userEmail',
                                                _emailController.text.trim());
                                          } else {
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
                                      } catch (e) {
                                        // Handle any errors that occur during sign in

                                      }
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
