
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/models/DynamicListsModel.dart';
import '../../common/models/conflict_model_hive.dart';
import '../../common/themeHelper.dart';

class EditConflict extends StatefulWidget {
  final Function(int) changeIndex;
  final int currentIndex;
  final Conflict conflictData;
  final Function( Conflict ) changeData;

  const EditConflict({
    super.key,
    required this.conflictData,
    required this.changeIndex,
    required this.currentIndex,
    required this.changeData
  });

  @override
  _EditConflictState createState() => _EditConflictState();
}

class _EditConflictState extends State<EditConflict> {
  List<DynamicListsModel> attributeList = [];
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _villageNameController;
  late TextEditingController _cNoController;
  late TextEditingController _pincodeNameController;
  late TextEditingController _personNameController;
  late TextEditingController _personAgeController;
  late TextEditingController _personGenderController;
  late TextEditingController _spCausingDeathController;
  late TextEditingController _notesController;

  Map<String, dynamic>? selectedRange;
  Map<String, dynamic>? selectedRound;
  Map<String, dynamic>? selectedBt;
  String? selectedConflict;

  Map<String, dynamic> dynamicLists = {};

  @override
  void initState() {
    super.initState();
    fetchDynamicLists();

    _villageNameController = TextEditingController(text: widget.conflictData.village_name);
    _cNoController = TextEditingController(text: widget.conflictData.cNoName);
    _pincodeNameController = TextEditingController(text: widget.conflictData.pincodeName);
    _personNameController = TextEditingController(text: widget.conflictData.person_name);
    _personAgeController = TextEditingController(text: widget.conflictData.person_age);
    _personGenderController = TextEditingController(text: widget.conflictData.person_gender);
    _spCausingDeathController = TextEditingController(text: widget.conflictData.sp_causing_death);
    _notesController = TextEditingController(text: widget.conflictData.notes);

    selectedConflict = widget.conflictData.conflict;
  }

  Future<void> fetchDynamicLists() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('dynamic_lists')
        .get();

    final userData = userSnapshot.docs;

    for( var item in userData ) {
      dynamicLists[item.id] = item['values'];
    }

    // setting the dynamic list for conflict with value none
    dynamicLists['conflict']?.add('None');

    setState(() {
      selectedRange = dynamicLists['range'].where( (range) => range['name'] == widget.conflictData.range ).first;
      selectedRound = dynamicLists['round'].where( (round) => round['name'] == widget.conflictData.round ).first;
      selectedBt = dynamicLists['beat'].where( (beat) => beat['name'] == widget.conflictData.bt ).first;

      print( dynamicLists['range'] );

      selectedConflict = widget.conflictData.conflict.toString();
    });
  }

  void _onItemTapped(int index) {
    widget.changeIndex( index );
    Navigator.of(context).pop();
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
          'Edit Conflict',
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
        currentIndex: widget.currentIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: dynamicLists.isEmpty ? Center(
          child: CircularProgressIndicator(),
        ) : Padding(
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
                    decoration: ThemeHelper().textInputDecoration('Range', 'Enter Range'),
                    value: selectedRange,
                    items: dynamicLists['range'].map<DropdownMenuItem<Map<String, dynamic>>>( (range) => DropdownMenuItem<Map<String, dynamic>>(
                      value: range,
                      child: Text( range['name'] ),
                    ) ).toList(),
                    onChanged: (Map<String, dynamic>? value) {
                      setState(() {
                        selectedRange = value;
                        selectedRound = dynamicLists['round'].where( (round) => round['range_id'] == selectedRange!['id'] ).toList().first;
                        selectedBt = dynamicLists['beat'].where( (beat) => beat['round_id'] == selectedRound!['id'] ).toList().first;
                      });
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
                    decoration: ThemeHelper()
                        .textInputDecoration('Round', 'Enter Round'),
                    value: selectedRound,
                    items: dynamicLists['round']!.where( (round) => round['range_id'] == selectedRange!['id'] ).map<DropdownMenuItem<Map<String, dynamic>>>(
                          (round) => DropdownMenuItem<Map<String, dynamic>>(
                        child: Text(round['name']),
                        value: round,
                      ),
                    )
                        .toList(),
                    onChanged: (Map<String, dynamic>? value) {
                      setState(() {
                        selectedRound = value;
                        selectedBt = dynamicLists['beat'].where( (beat) => beat['round_id'] == selectedRound!['id'] ).toList().first;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Beats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                    decoration: ThemeHelper()
                        .textInputDecoration('Beats', 'Enter Beats'),
                    value: selectedBt,
                    items: dynamicLists['beat']!.where( (beat) => beat['round_id'] == selectedRound!['id'] ).map<DropdownMenuItem<Map<String, dynamic>>>( (beat) => DropdownMenuItem<Map<String, dynamic>>(
                      child: Text(beat['name'] ),
                      value: beat,
                    ) ).toList(),
                    onChanged: (Map<String, dynamic>? value) {
                      selectedBt = value;
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
                    items: dynamicLists['conflict']!.map<DropdownMenuItem<String>>( (e) => DropdownMenuItem<String>(
                      child: Text(e.toString()),
                      value: e.toString(),
                    )).toList(),
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
                        'person_name', 'Enter Name'),
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
                    height: 10,
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // Update the tiger data in the Firebase Firestore
                        final CollectionReference docRef = FirebaseFirestore.instance.collection('forestdata');
                        final Map<String, dynamic> userData = {
                          "range" : selectedRange,
                          "round" : selectedRound,
                          'bt' : selectedBt,
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
                          await docRef.doc( widget.conflictData.id )
                            .get()
                            .then((docSnapshot) {
                              docSnapshot.reference.update(userData);
                            });

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conflict updated successfully'),
                            ),
                          );

                          final Conflict newData = Conflict(
                              id: widget.conflictData.id,
                              range: selectedRange!['name'],
                              round: selectedRound!['name'],
                              bt: selectedBt!['name'],
                              village_name: _villageNameController.text,
                              cNoName: _cNoController.text,
                              pincodeName: _pincodeNameController.text,
                              conflict: selectedConflict!,
                              person_name: _personNameController.text,
                              person_age: _personAgeController.text,
                              person_gender: _personGenderController.text,
                              sp_causing_death: _spCausingDeathController.text,
                              notes: _notesController.text,
                              imageUrl: widget.conflictData.imageUrl,
                              userName: widget.conflictData.userName,
                              userEmail: widget.conflictData.userEmail,
                              location: widget.conflictData.location,
                              userContact: widget.conflictData.userContact,
                              userImage: widget.conflictData.userImage,
                              datetime: widget.conflictData.datetime
                          );


                          // passing the data to previous screen for updating
                          widget.changeData( newData );

                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $error'),
                            ),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric( vertical: 18.0),
                      child: const Text('Save'),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
