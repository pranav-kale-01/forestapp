// ignore_for_file: unused_field, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _contactNumber = '';
  String _aadharNumber = '';
  String _forestId = '';
  File? _imageFile;
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection('users');

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  bool _isProcessing = false;

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
            'Add Guard',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        // elevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _getImage,
                    child: Container(
                      height: 150.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 50.0,
                                ),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _name = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      } else if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _email = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _password = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a contact number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _contactNumber = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Aadhar Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a aadhar number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _aadharNumber = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Forest ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Forest ID';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _forestId = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 3, 8, 35),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isProcessing = true;
                              });

                              // Check if email already exists in database
                              final CollectionReference usersRef =
                                  FirebaseFirestore.instance
                                      .collection('users');
                              final QuerySnapshot emailSnapshot = await usersRef
                                  .where('email', isEqualTo: _email)
                                  .get();
                              if (emailSnapshot.docs.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Email already exists'),
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                setState(() {
                                  _isProcessing = false;
                                });
                                return;
                              }

                              // Upload the image to Firebase Storage and get the URL
                              final Reference storageRef = FirebaseStorage
                                  .instance
                                  .ref()
                                  .child('user-images')
                                  .child(_imageFile!.path);
                              final UploadTask uploadTask =
                                  storageRef.putFile(_imageFile!);
                              final TaskSnapshot downloadUrl =
                                  await uploadTask.whenComplete(() => null);
                              final String imageUrl =
                                  await downloadUrl.ref.getDownloadURL();

                              // Add the user data to the Firebase Firestore
                              final Map<String, dynamic> userData = {
                                'name': _name,
                                'email': _email,
                                'password': _password,
                                'contactNumber': _contactNumber,
                                'imageUrl': imageUrl,
                                'aadharNumber': _aadharNumber,
                                'forestID': _forestId,
                              };
                              try {
                                await usersRef.add(userData);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User added successfully'),
                                  ),
                                );
                                _formKey.currentState!.reset();
                                setState(() {
                                  _imageFile = null;
                                });
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $error'),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isProcessing = false;
                                });
                              }
                            }
                          },
                    child: _isProcessing
                        ? CircularProgressIndicator()
                        : const Text('Save'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
