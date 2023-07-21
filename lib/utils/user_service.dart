import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forestapp/common/models/user.dart';
import 'package:forestapp/screens/Admin/homeAdmin.dart';
import 'package:forestapp/screens/User/homeUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:forestapp/utils/utils.dart' show baseUrl;

class UserService {
  static void loginAsAdmin(
      BuildContext context, String email, String password) async {
    try {
      // sending a request to API
      var request = http.MultipartRequest(
          'POST', Uri.parse('${baseUrl}admin/admin_login'));
      request.fields.addAll({'email': email, 'password': password});

      // getting the response
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Get an instance of shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Store the email in shared preferences
        prefs.setBool('isAdmin', true);
        // prefs.setString('userEmail', email);

        // Navigate to the HomeAdmin screen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeAdmin(),
          ),
        );
      } else {
        // TODO: handle Errors here
        Map<String, dynamic> jsonResponse =
            jsonDecode(await response.stream.bytesToString());
        String message = jsonResponse['message'];

        // if ( message == 'user-not-found') {
        //   showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         title: const Text(
        //             'User not found'),
        //         content: const Text(
        //             'No user found for that email.'),
        //         actions: <Widget>[
        //           ElevatedButton(
        //             onPressed: () {
        //               Navigator.of(context)
        //                   .pop();
        //             },
        //             child: const Text('OK'),
        //           ),
        //         ],
        //       );
        //     },
        //   );
        // }
        if (message == 'Wrong Email or password') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Wrong Credentials'),
                content: const Text(
                    'Wrong Email or Password provided for that user.'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }

      // Get the user document from Firestore based on the email entered
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     .collection('users')
      //     .where('email', isEqualTo: email )
      //     .get();

      // if (querySnapshot.docs.length != 0 ) {
      //   // Get the first document from the query snapshot
      //   DocumentSnapshot userDoc = querySnapshot.docs.first;
      //
      //   // checking if user has proper privileges or not
      //   if (!userDoc.get('privileged_user')) {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AlertDialog(
      //           title: const Text(
      //               'User is an Admin'),
      //           content: const Text(
      //               'This User does not have the privilege to login as an Admin.'),
      //           actions: <Widget>[
      //             ElevatedButton(
      //               onPressed: () {
      //                 Navigator.of(context)
      //                     .pop();
      //               },
      //               child: const Text('OK'),
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //     return;
      //   }
      // }
      // else {
      //   return;
      // }
    } catch (e, s) {
      // Handle any errors that occur during sign in
      debugPrint(e.toString());
      debugPrint(s.toString());
    }

    // // Authenticate the user with Firebase
    // FirebaseAuth.instance.signInWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // ).then((value) async {
    //   await FirebaseAuth.instance.setPersistence(
    //       Persistence.LOCAL);
    // }).catchError((error) {
    //   // handle error
    // });
  }

  static void loginAsUser(
      BuildContext context, String email, String password) async {
    try {
      // sending a request to API
      var request = http.MultipartRequest(
          'POST', Uri.parse('${baseUrl}guard/guard_login'));
      request.fields.addAll({'email': email, 'password': password});

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Navigate to the HomeAdmin screen on successful login
        Map<String, dynamic> user =
            jsonDecode(await response.stream.bytesToString());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeUser(
              userEmail: email,
            ),
          ),
        );

        // Get an instance of shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Store the email in shared preferences
        prefs.setString('userEmail', email);

        // Store the latitude and longitude in shared preferences
        prefs.setString('latitude', user['latitude']);
        prefs.setString('longitude', user['longitude']);
        prefs.setString(
            'radius', (double.parse(user['radius']) * 1000).toString());
      } else {
        print(response.reasonPhrase);
        Map<String, dynamic> jsonResponse =
            jsonDecode(await response.stream.bytesToString());
        String message = jsonResponse['message'];

        if (message == "Wrong Password") {
          // Show an alert dialog for wrong password
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Wrong password'),
                content: const Text('Wrong password provided for that user.'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (message == "Email Does Not Exist") {
          // Show an alert dialog for user not found
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('User not found'),
                content: const Text('No user found for that email.'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }

      return;

      // Get the user document from Firestore based on the email entered
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     .collection('users')
      //     .where('email', isEqualTo: email )
      //     .get();
      //
      // if (querySnapshot.docs.isNotEmpty) {
      //   // Get the first document from the query snapshot
      //   DocumentSnapshot userDoc = querySnapshot.docs.first;
      //
      //   // checking if user has proper privileges or not
      //   if( userDoc.get('privileged_user') ) {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AlertDialog(
      //           title: const Text(
      //               'User is an Admin'),
      //           content: const Text(
      //               'The User you are trying to log in with is an Admin. Please Login using Admin to continue'),
      //           actions: <Widget>[
      //             ElevatedButton(
      //               onPressed: () {
      //                 Navigator.of(context)
      //                     .pop();
      //               },
      //               child: const Text('OK'),
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //     return;
      //   }
      //
      //   // Compare the entered password with the password in Firestore
      //   if (userDoc.get('password') == password ) {
      //
      //   }
      //   else {
      //
      //   }
      // } else {
      //
      // }
    } catch (e, s) {
      // Handle any errors that occur during sign in
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  static Future<User> fetchUserProfileData(String userEmail) async {
    // calling the api to get data
    var request = http.MultipartRequest(
        'GET', Uri.parse('${baseUrl}/admin/get_guard/$userEmail'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> userData =
          jsonDecode(await response.stream.bytesToString());

      return User(
          name: userData['name'],
          email: userData['email'],
          contactNumber: userData['contact'],
          imageUrl: userData['profile_photo'],
          aadharNumber: userData['aadhar_number'],
          forestId: int.parse(userData['forest_id']),
          longitude: double.parse(userData['longitude']),
          latitude: double.parse(userData['latitude']),
          radius: int.parse(userData['radius']),
          forestID: userData['forest_id'],
          password: userData['password'],
          aadharImageUrl: '',
          forestIDImageUrl: ''
      );
    } else {
      return jsonDecode(await response.stream.bytesToString());
    }

    // final userSnapshot = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('email', isEqualTo: userEmail )
    //     .get();
    //
    // final userData = userSnapshot.docs.first.data();

    // return userData;
  }

  static Future<List<User>> getAllGuards() async {
    try {
      // getting the list of guards from the api
      var request =
          http.Request('GET', Uri.parse('${baseUrl}/admin/get_all_guards'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        List<dynamic> guardsList =
            jsonDecode(await response.stream.bytesToString());

        final List<User> profileDataList = guardsList
            .map((userData) => User(
                name: userData['name'],
                email: userData['email'],
                contactNumber: userData['contact'],
                imageUrl: userData['profile_photo'],
                aadharNumber: userData['aadhar_number'],
                forestId: int.parse(userData['forest_id']),
                longitude: double.parse(userData['longitude']),
                latitude: double.parse(userData['latitude']),
                radius: int.parse(userData['radius']),
                forestID: userData['forest_id'],
                password: userData['password'],
                aadharImageUrl: '',
                forestIDImageUrl: ''
            )).toList();

        return profileDataList;
      } else {
        print(response.reasonPhrase);
        print(await response.stream.bytesToString());
        return [];
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return [];
    }
  }

  static Future<bool> updateUser(User updatedUser) async {
    try {
      // calling the API for updating user
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://aishwaryasoftware.xyz/conflict/admin//update_guard'));
      request.fields.addAll({
        'name': updatedUser.name,
        'email': updatedUser.email,
        'password': updatedUser.password!,
        'contact': updatedUser.contactNumber,
        'aadhar_number': updatedUser.aadharNumber,
        'forest_id': updatedUser.forestID,
        'latitude': updatedUser.latitude.toString(),
        'longitude': updatedUser.longitude.toString(),
        'radius': updatedUser.radius.toString()
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        print('no changes');
        print( await response.stream.bytesToString( ));
        return false;
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return false;
    }
  }
}
