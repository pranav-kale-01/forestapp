// ignore_for_file: unused_field, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/user.dart';
import 'package:forestapp/utils/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../common/themeHelper.dart';

class EditUserScreen extends StatefulWidget {
  final User user;
  final Function(User) updateList;
  final Function(int) changeIndex;

  const EditUserScreen({
    super.key,
    required this.user,
    required this.changeIndex,
    required this.updateList
  });

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _password;
  late String _contactNumber;
  late String _aadharNumber;
  late String _forestId;
  File? _imageFile;
  NetworkImage? _networkImage;
  String? imageUrl;
  String? longitude;
  String? latitude;
  String? radius;

  @override
  void initState( ) {
    super.initState();

    // setting text fields
    _name = widget.user.name;
    _email = widget.user.email;
    _password = widget.user.password!;
    _contactNumber = widget.user.contactNumber;
    _aadharNumber = widget.user.aadharNumber;
    _forestId = widget.user.forestId.toString();

    _setImage();
  }

  Future<void> _setImage() async {
    setState(() {
      _networkImage = NetworkImage( widget.user.imageUrl );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    File file = File( pickedFile?.path as String );

    // updating the file to cloud firestore
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('user-images')
        .child("${widget.user.forestId.toString}/${widget.user.forestId.toString}.jpg");

    final UploadTask uploadTask = storageRef.putFile(file);
    final TaskSnapshot downloadUrl = await uploadTask.whenComplete(() => null);

    imageUrl = await downloadUrl.ref.getDownloadURL();

    setState(() {
      _networkImage = NetworkImage( imageUrl! );
    });
  }

  void _onItemTapped(int index) {
    widget.changeIndex( index );
    Navigator.of(context).pop();
  }

  Future<void> editUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if( imageUrl == null ) {
        imageUrl = widget.user.imageUrl;
      }

      final User updatedUser = User(
          name: _name,
          email: _email,
          password: _password,
          contactNumber: _password,
          imageUrl: imageUrl!,
          aadharNumber: _aadharNumber,
          forestId: int.parse( _forestId ),
          longitude: double.parse(longitude!),
          latitude: double.parse(latitude!),
          radius: int.parse( radius! ),
          aadharImageUrl: '',
          forestIDImageUrl: '',
      );

      bool userUpdated  = await UserService.updateUser( context, updatedUser );

      if( userUpdated ) {
        // updating the parent list
        widget.updateList( updatedUser );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Edit User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric( horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: _networkImage as ImageProvider,
                              fit: BoxFit.cover
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
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
                                          setState(() {
                                            _pickImage(ImageSource.camera);
                                          });

                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: const Text('Choose from gallery'),
                                        onTap: () {
                                          setState(() {
                                            _pickImage(ImageSource.gallery);
                                          });

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(1, 3),
                                  )
                                ]
                            ),
                            child: Icon(
                              Icons.edit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Name', 'Enter Name'
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    initialValue: widget.user.name,
                    onSaved: (value) {
                      _name = value!;
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
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                      'Email', 'Enter Email'
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      // } else if (!value.contains('@') || !value.contains('.')) {
                      //   return 'Please enter a valid email';
                      // }
                      return null;
                    },
                    initialValue: widget.user.email,
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),

                  const SizedBox(height: 16.0),
                  Text(
                    "Passsword",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
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
                    initialValue: widget.user.password,
                    onSaved: (value) {
                      _password = value!;
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
                  const SizedBox(height: 16.0),
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
                    initialValue: widget.user.contactNumber,
                    onSaved: (value) {
                      _contactNumber = value!;
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
                  const SizedBox(height: 16.0),
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
                    initialValue: widget.user.aadharNumber,
                    onSaved: (value) {
                      _aadharNumber = value!;
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
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration:ThemeHelper().textInputDecoration(
                        'Forest ID', 'Enter Forest ID'
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Forest ID';
                      }
                      return null;
                    },
                    initialValue: widget.user.forestId.toString(),
                    onChanged: ( value ) {
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
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration:ThemeHelper().textInputDecoration(
                        'Latitude', 'Enter Latitude'
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Latitude';
                      }
                      return null;
                    },
                    initialValue: widget.user.latitude.toString(),
                    onSaved: (value) {
                      latitude = value!;
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
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration:ThemeHelper().textInputDecoration(
                        'Longitude', 'Enter Longitude'
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Longitude';
                      }
                      return null;
                    },
                    initialValue: widget.user.longitude.toString(),
                    onSaved: (value) {
                      longitude = value!;
                    },
                  ),

                  const SizedBox(height: 16.0),
                  Text(
                    "Radius",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration:ThemeHelper().textInputDecoration(
                        'Radius', 'Enter Radius'
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Radius';
                      }
                      return null;
                    },
                    initialValue: widget.user.radius.toString(),
                    onSaved: (value) {
                      radius = value!;
                    },
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
                    onPressed: editUser,
                    child: Padding(
                      padding: const EdgeInsets.symmetric( vertical: 18.0),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
