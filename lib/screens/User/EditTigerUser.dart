// ignore_for_file: unused_field, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forestapp/common/models/ConflictModel.dart';
import 'package:forestapp/screens/Admin/ForestDataScreen.dart';

import '../../common/themeHelper.dart';

class EditTigerUser extends StatefulWidget {
  final ConflictModel conflictData;
  const EditTigerUser({super.key, required this.conflictData});

  @override
  _EditTigerUserState createState() => _EditTigerUserState();
}

class _EditTigerUserState extends State<EditTigerUser> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _villageNameController;
  late TextEditingController _cNoController;
  late TextEditingController _pincodeNameController;
  late TextEditingController _personNameController;
  late TextEditingController _personAgeController;
  late TextEditingController _personGenderController;
  late TextEditingController _spCausingDeathController;
  late TextEditingController _notesController;


  List<DropdownMenuItem<String>> get rangeDropdownItems{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("1"),value: "1"),
      DropdownMenuItem(child: Text("2"),value: "2"),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get roundDropdownItems{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("1"),value: "1"),
      DropdownMenuItem(child: Text("2"),value: "2"),
      DropdownMenuItem(child: Text("3"),value: "3"),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get getConflictDropdownItems{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Human injured"),value: "human_injured"),
      DropdownMenuItem(child: Text("Human Killed"),value: "human_killed"),
      DropdownMenuItem(child: Text("Cattle Injured"),value: "cattle_injured"),
      DropdownMenuItem(child: Text("Cattle Killed"),value: "cattle_killed"),
      DropdownMenuItem(child: Text("Crop damaged"),value: "crop_damaged"),
    ];
    return menuItems;
  }

  late String selectedRange;
  late String selectedRound;
  late String selectedConflict;


  final CollectionReference _userRef = FirebaseFirestore.instance.collection('forestdata');
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    _villageNameController = TextEditingController(text: widget.conflictData.village_name);
    _cNoController = TextEditingController(text: widget.conflictData.cNoName);
    _pincodeNameController = TextEditingController(text: widget.conflictData.pincodeName);
    _personNameController = TextEditingController(text: widget.conflictData.person_name);
    _personAgeController = TextEditingController(text: widget.conflictData.person_age);
    _personGenderController = TextEditingController(text: widget.conflictData.person_gender);
    _spCausingDeathController = TextEditingController(text: widget.conflictData.sp_causing_death);
    _notesController = TextEditingController(text: widget.conflictData.notes);

    selectedRange = widget.conflictData.range;
    selectedRound = widget.conflictData.round;
    selectedConflict = widget.conflictData.conflict;
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
          'Edit Tiger',
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
                  SizedBox(
                    height: 30,
                  ),

                  // fields for all values
                  Text(
                    "Range",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Range', 'Enter Range'
                    ),
                    value: selectedRange,
                    items: rangeDropdownItems,
                    onChanged: (Object? value) {
                      selectedRange = value.toString();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Round",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Round', 'Enter Round'
                    ),
                    value: selectedRound,
                    items: roundDropdownItems,
                    onChanged: (Object? value) {
                      selectedRound = value.toString();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Village Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _villageNameController,
                    decoration: ThemeHelper()
                        .textInputDecoration(
                        'Village name', 'Enter Village name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "CN/S.NO name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _cNoController,
                    decoration: ThemeHelper()
                        .textInputDecoration(
                        'cn/s.no_name', 'Enter CN/S.NO name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Pincode Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _pincodeNameController,
                    decoration: ThemeHelper()
                        .textInputDecoration(
                        'pincode_name', 'Enter pincode Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Conflict",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        'Conflict', 'Select Conflict'
                    ),
                    value: selectedConflict,
                    items: getConflictDropdownItems,
                    onChanged: (Object? value) {
                      selectedConflict = value.toString();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

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
                    controller: _personNameController,
                    decoration: ThemeHelper()
                        .textInputDecoration(
                        'person_name', 'Enter name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Age",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _personAgeController,
                    decoration: ThemeHelper()
                        .textInputDecoration(
                        'person_age', 'Enter Age'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Gender",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _personGenderController,
                    decoration: ThemeHelper()
                        .textInputDecoration(
                        'person_gender', 'Enter Gender'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),


                  Text(
                    "sp causing death",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _spCausingDeathController,
                    decoration: ThemeHelper()
                        .textInputDecoration(
                        'sp_causing_death', 'sp causing death'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "notes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      controller: _notesController,
                      decoration: ThemeHelper()
                          .textInputDecoration(
                          'notes', 'Notes'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();



                        // Update the tiger data in the Firebase Firestore
                        final CollectionReference docRef = FirebaseFirestore.instance.collection('forestdata');
                        final Map<String, dynamic> userData = {
                          'id': docRef.id,
                          "range" : selectedRange,
                          "round" : selectedRound,
                          "village_name" : _villageNameController.text,
                          "c_no_name" : _cNoController.text,
                          "conflict" : selectedConflict,
                          "person_name" : _personNameController.text,
                          "pincode_name" : _pincodeNameController.text,
                          "person_age" : _personAgeController.text,
                          "person_gender" : _personGenderController.text,
                          "sp_causing_death" : _spCausingDeathController.text,
                          "notes" : _notesController.text,
                          'createdAt': DateTime.now(),
                        };

                        try {
                          await docRef
                              .where('id', isEqualTo: widget.conflictData.id)
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.forEach((doc) {
                              docRef.doc(doc.id).update(userData);
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
                  ),

                  // TextFormField(
                  //   decoration: const InputDecoration(
                  //     labelText: 'Name',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter a tiger name';
                  //     }
                  //     return null;
                  //   },
                  //   initialValue: widget.tiger.village_name,
                  //   onSaved: (value) {
                  //     _name = value!;
                  //   },
                  // ),
                  // const SizedBox(height: 16.0),
                  // TextFormField(
                  //   keyboardType: TextInputType.number,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Description',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter an Description';
                  //     }
                  //     return null;
                  //   },
                  //   initialValue: widget.tiger.village_name,
                  //   onSaved: (value) {
                  //     _description = value!;
                  //   },
                  // ),
                  // const SizedBox(height: 16.0),
                  // TextFormField(
                  //   keyboardType: TextInputType.number,
                  //   decoration: const InputDecoration(
                  //     labelText: 'No. of Cubs',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter a Cubs';
                  //     }
                  //     return null;
                  //   },
                  //   // initialValue: widget.tiger.noOfCubs.toString(),
                  //   onSaved: (value) {
                  //     _noOfCubs = value!;
                  //   },
                  // ),
                  // const SizedBox(height: 16.0),
                  // TextFormField(
                  //   decoration: const InputDecoration(
                  //     labelText: 'No. of Tigers',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   keyboardType: TextInputType.phone,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter a Tigers';
                  //     }
                  //     return null;
                  //   },
                  //   // initialValue: widget.tiger.noOfTigers.toString(),
                  //   onSaved: (value) {
                  //     _noOfTigers = value!;
                  //   },
                  // ),
                  // const SizedBox(height: 16.0),
                  // const SizedBox(height: 16.0),
                  // TextFormField(
                  //   decoration: const InputDecoration(
                  //     labelText: 'Remark',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   keyboardType: TextInputType.phone,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter a remark here';
                  //     }
                  //     return null;
                  //   },
                  //   initialValue: widget.tiger.village_name,
                  //   onSaved: (value) {
                  //     _remark = value!;
                  //   },
                  // ),
                  //
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
