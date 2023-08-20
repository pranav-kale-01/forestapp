// ignore_for_file: unused_field, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:forestapp/utils/user_service.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/themeHelper.dart';

class AddUserScreen extends StatefulWidget {
  final Function(int) changeIndex;

  const AddUserScreen({
    super.key,
    required this.changeIndex,
  });

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
  String? longitude;
  String? latitude;
  String? radius;
  File? _image;
  File? _aadharImage;
  File? _forestIDImage;
  String? _currentLocation;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _pickAadharImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _aadharImage = File(pickedFile!.path);
    });
  }

  Future<void> _pickForestIDImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _forestIDImage = File(pickedFile!.path);
    });
  }

  Future<void> addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final Map<String, dynamic> userData = {
          'name': _name,
          'email': _email,
          'password': _password,
          'contactNumber': _contactNumber,
          'aadharNumber': _aadharNumber,
          'forestID': _forestId,
          'image': _image,
          'aadharImage' : _aadharImage,
          'forestIDImage' : _forestIDImage,
          'privileged_user' : false,
          'latitude' :  latitude!,
          'longitude' : longitude!,
          'radius' : int.parse( radius! ) * 1000,
        };

        bool success = await UserService.addUser( context, userData );

        if( success ) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User added successfully'),
            ),
          );

          _formKey.currentState!.reset();
          setState(() {
            _imageFile = null;
          });
          Navigator.of(context).pop();
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('There was and error adding the user'),
            ),
          );
        }
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
  }

  void _onItemTapped(int index) {
    widget.changeIndex( index );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_sharp),
            label: 'Guard',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Forest Data',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          height: 120,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              )
          ),
        ),
        title: const Text(
          'Add Guard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Name', 'Enter Name'),
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
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                      'Email', 'Enter Email'
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
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: ThemeHelper().textInputDecoration(
                      'Password', 'Enter Password'
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
                  Text(
                    "Contact Number",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                      'Contact Number', 'Enter Contact Number'
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
                  Text(
                    "Aadhar Number",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                      'Aadhar Number', 'Enter Aadhar Number'
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
                  Text(
                    "Forest ID",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'ForestID', 'Enter ForestID'
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
                  Text(
                    "Latitude",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Latitude', 'Enter Latitude'
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Latitude';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      latitude = value;
                    },
                  ),

                  const SizedBox(height: 16.0),
                  Text(
                    "Longitude",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Longitude', 'Enter Longitude'
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a longitude';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      longitude = value;
                    },
                  ),

                  const SizedBox(height: 16.0),
                  Text(
                    "Radius in KM",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Radius', 'Enter Radius in KM'
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Radius';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      radius = value;
                    },
                  ),

                  const SizedBox(height: 16.0),
                  if (_image != null)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade400),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )
                        )
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
                    child: Padding(
                        padding: const EdgeInsets.symmetric( vertical: 20.0, ),
                        child: Text(_image == null ? 'Add Photo' : 'Change Photo')
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  if (_aadharImage != null)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_aadharImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade400),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )
                        )
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
                                    _pickAadharImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from gallery'),
                                  onTap: () {
                                    _pickAadharImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric( vertical: 20.0, ),
                        child: Text( _aadharImage == null ? 'Add Aadhar Photo' : 'Change Aadhar Photo')
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  if (_forestIDImage != null)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_forestIDImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade400),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )
                        )
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
                                    _pickForestIDImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from gallery'),
                                  onTap: () {
                                    _pickForestIDImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric( vertical: 20.0, ),
                        child: Text( _forestIDImage == null ? 'Add ForestID Photo' : 'Change ForestID Photo')
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade400),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )
                        )
                    ),
                    onPressed: _isProcessing ? null : addUser,
                    child: _isProcessing
                        ? const Padding(
                          padding: const EdgeInsets.symmetric( vertical: 20.0, ),
                          child: CircularProgressIndicator(),
                        ) : const Padding(
                            padding: const EdgeInsets.symmetric( vertical: 20.0, ),
                            child: Text('Save'),
                        ),
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
