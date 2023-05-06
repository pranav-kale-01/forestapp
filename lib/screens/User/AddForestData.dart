// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'homeUser.dart';

class ProfileData {
  final String name;
  final String email;
  final String contactNumber;
  final String imageUrl;
  // final int numberOfForestsAdded;

  ProfileData({
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.imageUrl,
    // required this.numberOfForestsAdded,
  });
}

//
class AddForestData extends StatefulWidget {
  const AddForestData({super.key});

  @override
  _AddForestDataState createState() => _AddForestDataState();
}

class _AddForestDataState extends State<AddForestData> {
  late String _userEmail;
  late ProfileData _profileData;
  String _selectedValue = 'no remark';

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    _initializeTitle();
  }

  Future<void> _initializeTitle() async {
    final uniqueTitle = await getUniqueTitle();
    _titleController.text = uniqueTitle;
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    setState(() {
      _userEmail = userEmail ?? '';
    });
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _userEmail)
        .get();
    final userData = userSnapshot.docs.first.data();
    setState(() {
      _profileData = ProfileData(
        name: userData['name'],
        email: userData['email'],
        contactNumber: userData['contactNumber'],
        imageUrl: userData['imageUrl'],
        // numberOfForestsAdded: userData['numberOfForestsAdded']
      );
    });
  }

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberOfTigersController = TextEditingController();
  final _numberOfCubsController = TextEditingController();
  File? _image;
  String? _currentLocation;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    });
  }

  void _onSubmitPressed() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show a loading spinner while the data is being uploaded
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
    try {
      // Upload the image to Cloud Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('forest_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Get the current location
      final position = await Geolocator.getCurrentPosition();
      final location = GeoPoint(position.latitude, position.longitude);

      // Create a new document in the 'forestdata' collection
      final docRef = FirebaseFirestore.instance.collection('forestdata').doc();
      final data = {
        'id': docRef.id,
        'number_of_tiger': int.parse(_numberOfTigersController.text.trim()),
        'number_of_cubs': int.parse(_numberOfCubsController.text.trim()),
        'remark': _selectedValue,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'location': location,
        'user_name': _profileData.name,
        'user_email': _profileData.email,
        'user_contact': _profileData.contactNumber,
        'user_imageUrl': _profileData.imageUrl,
        'createdAt': DateTime.now(),
      };

      await docRef.set(data);

      _titleController.clear();
      _descriptionController.clear();

      // Hide the loading spinner
      Navigator.pop(context);

      // Show an alert dialog indicating success
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Data added successfully.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomeUser(
                        title: 'title',
                      ),
                    ),
                    (route) => false);
              },
            ),
          ],
        ),
      );
    } catch (error) {
      // Hide the loading spinner
      Navigator.pop(context);

      // Show an alert dialog indicating failure
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to upload data.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomeUser(
                        title: 'title',
                      ),
                    ),
                    (route) => false);
              },
            ),
          ],
        ),
      );
    }
  }

  Future<String> getUniqueTitle() async {
    int counter = 0;
    String uniqueTitle = "unknown";
    bool titleExists = true;

    while (titleExists) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('forestdata')
          .where('title', isEqualTo: uniqueTitle)
          .get();

      if (querySnapshot.docs.isEmpty) {
        titleExists = false;
      } else {
        counter++;
        uniqueTitle = 'unknown($counter)';
      }
    }

    return uniqueTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        flexibleSpace: Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )),
        // title: const Text('Pench MH'),
        title: const Center(
          child: Text(
            'Add Forest Data',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        // elevation: 0.0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 60,
              ),
              if (_image != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 3, 8, 35), // Background color
                  // Text Color (Foreground color)
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take a photo'),
                              onTap: () {
                                _pickImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from gallery'),
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text(_image == null ? 'Add Photo' : 'Change Photo'),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numberOfTigersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of tigers',
                ),
                validator: (value) {
                  final intValue = int.tryParse(value!);
                  if (intValue == null) {
                    return 'Please enter a valid number';
                  }
                  // Add any additional validation checks here
                  return null;
                },
              ),
              TextFormField(
                controller: _numberOfCubsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of cubs',
                ),
                validator: (value) {
                  final intValue = int.tryParse(value!);
                  if (intValue == null) {
                    return 'Please enter a valid number';
                  }
                  // Add any additional validation checks here
                  return null;
                },
              ),
              DropdownButton<String>(
                value: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'no remark',
                    child: Text('Remark'),
                  ),
                  DropdownMenuItem(
                    value: 'injured',
                    child: Text('Injured'),
                  ),
                  DropdownMenuItem(
                    value: 'pregnant',
                    child: Text('Pregnant'),
                  ),
                  DropdownMenuItem(
                    value: 'killed',
                    child: Text('Killed'),
                  ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_currentLocation == null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Color.fromARGB(255, 3, 8, 35), // Background color
                    // Text Color (Foreground color)
                  ),
                  onPressed: _getCurrentLocation,
                  child: const Text('Get Current Location'),
                )
              else
                Text(_currentLocation!),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 3, 8, 35), // Background color
                  // Text Color (Foreground color)
                ),
                onPressed: _onSubmitPressed,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
