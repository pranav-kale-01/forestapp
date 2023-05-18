// ignore_for_file: unused_field, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forestapp/common/models/TigerModel.dart';
import 'package:forestapp/screens/Admin/ForestDataScreen.dart';
import 'package:forestapp/screens/Admin/HomeScreen.dart';



class EditTigerUser extends StatefulWidget {
  final TigerModel tiger;
  const EditTigerUser({super.key, required this.tiger});

  @override
  _EditTigerUserState createState() => _EditTigerUserState();
}

class _EditTigerUserState extends State<EditTigerUser> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _noOfCubs = '';
  String _noOfTigers = '';
  String _remark = '';

  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection('forestdata');

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  

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
            'Edit Tiger',
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
                 
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tiger name';
                      }
                      return null;
                    },
                    initialValue: widget.tiger.title,
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an Description';
                      } 
                      return null;
                    },
                    initialValue: widget.tiger.description,
                    onSaved: (value) {
                      _description = value!;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'No. of Cubs',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Cubs';
                      }
                      return null;
                    },
                    initialValue: widget.tiger.noOfCubs.toString(),
                    onSaved: (value) {
                      _noOfCubs = value!;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'No. of Tigers',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Tigers';
                      }
                      return null;
                    },
                    initialValue: widget.tiger.noOfTigers.toString(),
                    onSaved: (value) {
                      _noOfTigers = value!;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a remark here';
                      }
                      return null;
                    },
                    initialValue: widget.tiger.remark,
                    onSaved: (value) {
                      _remark = value!;
                    },
                  ),
            
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                       

                        // Update the tiger data in the Firebase Firestore
                        final CollectionReference tigersRef =
                            FirebaseFirestore.instance.collection('forestdata');
                        final Map<String, dynamic> userData = {
                          'title': _name,
                          'description': _description,
                          'number_of_cubs': _noOfCubs,
                          'number_of_tigers': _noOfTigers,
                          'remark': _remark
                        };
                        try {
                          await tigersRef
                              .where('id', isEqualTo: widget.tiger.id)
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.forEach((doc) {
                              tigersRef.doc(doc.id).update(userData);
                            });
                          });
                          
                         Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const ForestDataScreen()),
                              (route) => false);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tiger updated successfully'),
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
