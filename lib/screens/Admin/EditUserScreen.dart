// ignore_for_file: unused_field, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:forestapp/screens/Admin/MapScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'UserScreen.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditUserScreen({super.key, required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
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
            'Edit User',
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
                    initialValue: widget.user['name'] as String,
                    onSaved: (value) {
                      _name = value!;
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
                    initialValue: widget.user['email'] as String,
                    onSaved: (value) {
                      _email = value!;
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
                    initialValue: widget.user['password'] as String,
                    onSaved: (value) {
                      _password = value!;
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
                    initialValue: widget.user['contactNumber'] as String,
                    onSaved: (value) {
                      _contactNumber = value!;
                    },
                  ),
                  const SizedBox(height: 16.0),
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
                    initialValue: widget.user['aadharNumber'] as String,
                    onSaved: (value) {
                      _aadharNumber = value!;
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
                    initialValue: widget.user['forestID'] as String,
                    onSaved: (value) {
                      _forestId = value!;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // Upload the image to Firebase Storage and get the URL
                        String imageUrl = widget.user['imageUrl'];
                        if (_imageFile != null) {
                          final Reference storageRef = FirebaseStorage.instance
                              .ref()
                              .child('user-images')
                              .child(_imageFile!.path);
                          final UploadTask uploadTask =
                              storageRef.putFile(_imageFile!);
                          final TaskSnapshot downloadUrl =
                              await uploadTask.whenComplete(() => null);
                          imageUrl = await downloadUrl.ref.getDownloadURL();
                        }

                        // Update the user data in the Firebase Firestore
                        final CollectionReference usersRef =
                            FirebaseFirestore.instance.collection('users');
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
                          await usersRef
                              .where('email', isEqualTo: _email)
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.forEach((doc) {
                              usersRef.doc(doc.id).update(userData);
                            });
                          });
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const UserScreen()),
                              (route) => false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User updated successfully'),
                            ),
                          );
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $error'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Save'),
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
