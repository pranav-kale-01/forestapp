import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/user.dart';
import 'package:forestapp/contstant/constant.dart';
import 'package:forestapp/screens/Admin/homeAdmin.dart';
import 'package:forestapp/screens/User/homeUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:forestapp/utils/utils.dart' show baseUrl;

class UserService {
  static void loginAsAdmin(BuildContext context, String phone, String otp) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin//verify_otp'));
      request.fields.addAll({
        'phone': phone,
        'otp': otp
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Get an instance of shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Store the email in shared preferences
        prefs.setInt(SHARED_USER_TYPE, admin);

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
    } catch (e, s) {
      // Handle any errors that occur during sign in
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  static void loginAsUser(BuildContext context, String email, String password) async {
    try {
      // sending a request to API
      var request = http.MultipartRequest(
          'POST', Uri.parse('${baseUrl}guard/guard_login'));
      request.fields.addAll({'email': email, 'password': password});

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Navigate to the HomeAdmin screen on successful login
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
        prefs.setInt(SHARED_USER_TYPE, user);
        prefs.setString(SHARED_USER_EMAIL, email );
      }
      else {
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
    } catch (e, s) {
      // Handle any errors that occur during sign in
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  static Future<bool> sendOTP( String phoneNumber ) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/admin_login'));
    request.fields.addAll({
      'phone': phoneNumber,
    });

    http.StreamedResponse response = await request.send();

    if( response.statusCode != 200 ) {
      print( await response.stream.bytesToString( ) );
      print( response.reasonPhrase.toString() );
    }

    return response.statusCode == 200;
  }

  static Future<User?> getUser(String userEmail) async {
    // calling the api to get data
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}/admin/get_guard'));
    request.fields.addAll({
      'email': userEmail
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> userData = jsonDecode(await response.stream.bytesToString());

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
          password: userData['password'],
          aadharImageUrl: '',
          forestIDImageUrl: ''
      );
    } else {
      print( await response.stream.bytesToString( ) );
      print( response.reasonPhrase );
    }

    return null;
  }

  static Future<List<User>> getAllUsers() async {
    try {
      // getting the list of guards from the api
      var request = http.Request('GET', Uri.parse('${baseUrl}/admin/get_all_guards'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        List<dynamic> guardsList =
            jsonDecode(await response.stream.bytesToString());

        final List<User> profileDataList = guardsList
            .where( (user) => user['id'] != "-1" ).map((userData) => User(
                name: userData['name'],
                email: userData['email'],
                contactNumber: userData['contact'],
                imageUrl: userData['profile_photo'],
                aadharNumber: userData['aadhar_number'],
                forestId: int.parse(userData['forest_id']),
                longitude: double.parse(userData['longitude']),
                latitude: double.parse(userData['latitude']),
                radius: int.parse(userData['radius']),
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

  static Future<void> addUser( Map<String, dynamic> userData ) async {
    // Upload the image to Firebase Storage and get the URL
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('user-images')
        .child("${userData['forestID']}/${userData['forestID']}.jpg");

    UploadTask uploadTask = storageRef.putFile(userData['image']);
    TaskSnapshot downloadUrl = await uploadTask.whenComplete(() => null);
    final String imageUrl = await downloadUrl.ref.getDownloadURL();

    // Upload the aadhar image to Firebase Storage and get the URL
    storageRef = FirebaseStorage.instance
        .ref()
        .child('user-images')
        .child("${userData['forestID']}/${userData['forestID']}.jpg");

    uploadTask = storageRef.putFile( userData['aadharImage']);
    downloadUrl = await uploadTask.whenComplete(() => null);
    final String aadharImageUrl = await downloadUrl.ref.getDownloadURL();

    // Upload the forestId image to Firebase Storage and get the URL
    storageRef = FirebaseStorage.instance
        .ref()
        .child('user-images')
        .child("${userData['forestID']}/${userData['forestID']}.jpg");

    uploadTask = storageRef.putFile( userData['forestIDImage']);
    downloadUrl = await uploadTask.whenComplete(() => null);
    final String forestIdImageUrl = await downloadUrl.ref.getDownloadURL();

    var request = http.MultipartRequest('POST', Uri.parse('https://aishwaryasoftware.xyz/conflict/admin//add_guard'));
    request.fields.addAll({
      'name': userData['name'],
      'email': userData['email'],
      'password': userData['password'],
      'contact': userData['contactNumber'],
      'aadhar_number': userData['contactNumber'],
      'forest_id': userData['forestID'],
      'latitude': userData['latitude'],
      'longitude': userData['longitude'],
      'radius': userData['radius'],
      'forest_id_image': forestIdImageUrl,
      'aadhar_image' : aadharImageUrl,
      'image': imageUrl
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
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
        'forest_id': updatedUser.forestId.toString(),
        'latitude': updatedUser.latitude.toString(),
        'longitude': updatedUser.longitude.toString(),
        'radius': updatedUser.radius.toString()
      });

      print( request.fields.toString() );
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

  static Future<void> deleteUser( BuildContext context, String email ) async {
    try {
      // sending a request to API
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}/admin/delete_guard'));
      request.fields.addAll({
        'email': email
      });
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());

        // first deleting the images
        // Reference storageRef = FirebaseStorage.instance
        //     .ref()
        //     .child('user-images')
        //     .child("${guard.forestId.toString()}/${guard.forestId.toString()}.jpg");
        //
        // await storageRef.delete();
        //
        // storageRef = FirebaseStorage.instance
        //     .ref()
        //     .child('user-images')
        //     .child("${guard.forestId.toString()}/${guard.forestId.toString()}_aadhar.jpg");
        //
        // await storageRef.delete();
        //
        // storageRef = FirebaseStorage.instance
        //     .ref()
        //     .child('user-images')
        //     .child("${guard.forestId.toString()}/${guard.forestId.toString()}_forestID.jpg");
        //
        // await storageRef.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully.'),
          ),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found.'),
          ),
        );
      }

      // final snapshot = await FirebaseFirestore.instance
      //     .collection('users')
      //     .where('email', isEqualTo: guard.email)
      //     .get();

      // if (snapshot.docs.isNotEmpty) {
      //   // first deleting the images
      //   Reference storageRef = FirebaseStorage.instance
      //       .ref()
      //       .child('user-images')
      //       .child("${guard.forestId.toString()}/${guard.forestId.toString()}.jpg");
      //
      //   await storageRef.delete();
      //
      //   storageRef = FirebaseStorage.instance
      //       .ref()
      //       .child('user-images')
      //       .child("${guard.forestId.toString()}/${guard.forestId.toString()}_aadhar.jpg");
      //
      //   await storageRef.delete();
      //
      //   storageRef = FirebaseStorage.instance
      //       .ref()
      //       .child('user-images')
      //       .child("${guard.forestId.toString()}/${guard.forestId.toString()}_forestID.jpg");
      //
      //   await storageRef.delete();
      //
      //   // now deleting the record from Firestore database
      //   await snapshot.docs.first.reference.delete();
      //
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('User deleted successfully.'),
      //     ),
      //   );
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('User not found.'),
      //     ),
      //   );
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
        ),
      );
    }
  }
}
