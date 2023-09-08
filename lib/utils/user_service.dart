import 'dart:convert';

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>  Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 2,
          ),
        ),
      );

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

        // removing the progress bar
        Navigator.of(context).pop();

        // Navigate to the HomeAdmin screen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeAdmin(),
          ),
        );

        return;

      } else {
        Map<String, dynamic> jsonResponse = jsonDecode(await response.stream.bytesToString());
        String message = jsonResponse['message'];

        if (message == 'Phone Number Does not match') {
          // removing the progress bar
          Navigator.of(context).pop();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Wrong Credentials'),
                content: const Text(
                    'Phone Number does not match!'),
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
        else if( message == "Otp does not match" ) {
          // removing the progress bar
          Navigator.of(context).pop();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Incorrect OTP'),
                content: const Text(
                    'The OTP does not match. Please Enter a Valid OTP!'),
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

      // removing the progress bar
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  static Future<void> loginAsUser(BuildContext context, String email, String password) async {
    try {
      // sending a request to API
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}guard/guard_login'));
      request.fields.addAll({'email': email, 'password': password});

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // getting the user details
        User? currUser = await UserService.getUser(context, email);

        // Get an instance of shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Store the email in shared preferences
        prefs.setInt(SHARED_USER_TYPE, user);
        prefs.setString(SHARED_USER_EMAIL, email );
        prefs.setString(SHARED_USER_LONGITUDE, currUser!.longitude.toString() );
        prefs.setString(SHARED_USER_LATITUDE, currUser.latitude.toString() );
        prefs.setString(SHARED_USER_RADIUS, currUser.radius.toString() );
        prefs.setString(SHARED_USER_NAME, currUser.name.toString() );
        prefs.setString(SHARED_USER_CONTACT, currUser.contactNumber.toString() );
        prefs.setString(SHARED_USER_IMAGEURL, currUser.imageUrl.toString() );

        // Navigate to the HomeAdmin screen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeUser(
              userEmail: email,
            ),
          ),
        );
      }
      else {
        print(response.reasonPhrase);
        Map<String, dynamic> jsonResponse = jsonDecode(await response.stream.bytesToString());
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
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  static Future<bool> sendOTP( BuildContext context, String phoneNumber ) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/admin_login'));
    request.fields.addAll({
      'phone': phoneNumber,
    });

    http.StreamedResponse response = await request.send();
    Map<String, dynamic> jsonResponse = jsonDecode( await response.stream.bytesToString( ) );
    String message = jsonResponse['message'];

    // removing the progress bar
    Navigator.of(context).pop();

    if( response.statusCode != 200 ) {

      if (message == 'Phone Number Does not match') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Wrong Credentials'),
              content: const Text(
                  'Phone Number does not match!'),
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
      else {
        var jsonResponse = jsonDecode(await response.stream.bytesToString());
        // removing the progress bar
        Navigator.of(context).pop();

        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to send OTP. Error : ${jsonResponse.toString()}'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }

    return response.statusCode == 200;
  }

  static Future<User?> getUser(BuildContext context, String userEmail) async {
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
      print( response.reasonPhrase );
      var jsonResponse = jsonDecode(await response.stream.bytesToString());
      print( jsonResponse );
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload data. Error : ${jsonResponse.toString()}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    return null;
  }

  static Future<List<User>> getAllUsers( BuildContext context ) async {
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
        var jsonResponse = jsonDecode(await response.stream.bytesToString());
        print( jsonResponse );
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to upload data. Error : ${jsonResponse.toString()}'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );

        return [];
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload data. Error : ${e}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return [];
    }
  }

  static Future<bool> addUser( BuildContext context, Map<String, dynamic> userData ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/add_guard'));
      request.fields.addAll({
        'name': userData['name'].toString(),
        'email': userData['email'].toString(),
        'password': userData['password'].toString(),
        'contact': userData['contactNumber'].toString(),
        'aadhar_number': userData['contactNumber'].toString(),
        'forest_id': userData['forestID'].toString(),
        'latitude': userData['latitude'].toString(),
        'longitude': userData['longitude'].toString(),
        'radius':  ( userData['radius'] ).toString(),
      });

      request.files.add(await http.MultipartFile.fromPath('profile_photo', userData['image'].path ));
      request.files.add(await http.MultipartFile.fromPath('forest_id_photo', userData['aadharImage'].path));
      request.files.add(await http.MultipartFile.fromPath('aadhar_photo', userData['forestIDImage'].path ));

      http.StreamedResponse response = await request.send();


      if( response.statusCode != 200 ) {
        print("There was an error");
        var message =  await response.stream.bytesToString( );
        print(response.reasonPhrase);
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to upload data. Error : ${message}'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }

      return response.statusCode == 200;
    }
    catch( e, s ) {
      print( e );
      print( s );
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload data. Error : ${e}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return false;
    }
  }

  static Future<bool> updateUser(BuildContext context, User updatedUser) async {
    try {
      // calling the API for updating user
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('${baseUrl}admin/update_guard'));
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
        print( response.reasonPhrase );
        var jsonResponse = jsonDecode(await response.stream.bytesToString());
        print( jsonResponse );
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to upload data. Error : ${jsonResponse.toString()}'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        return false;
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload data. Error : ${e}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return false;
    }
  }

  static Future<bool> deleteUser( BuildContext context, String email ) async {
    try {
      // sending a request to API
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}/admin/delete_guard'));
      request.fields.addAll({
        'email': email
      });
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());

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

      return response.statusCode == 200;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
        ),
      );
      return false;
    }
  }
}
