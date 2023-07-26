import 'package:flutter/material.dart';
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/dynamic_list_service.dart';

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
  Map<String, dynamic>? selectedConflict;

  Map<String, dynamic> dynamicLists = {};

  Future<void> editConflict() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> userData = {
        "id" : widget.conflictData.id,
        "email": widget.conflictData.userEmail,
        "range" : selectedRange,
        "round" : selectedRound,
        'beat' : selectedBt,
        "village_name" : _villageNameController.text,
        "cn_sr_name" : _cNoController.text,
        "pincode" : _pincodeNameController.text,
        "conflict" :  selectedConflict,
        "name" : _personNameController.text,
        "age" : _personAgeController.text,
        "gender" : _personGenderController.text,
        "sp_causing_death" : _spCausingDeathController.text,
        "notes" : _notesController.text,
        "latitude": widget.conflictData.location.latitude,
        "longitude": widget.conflictData.location.longitude,
        "contact" : widget.conflictData.userContact,
        "photo" : widget.conflictData.imageUrl,
        "user_name" : widget.conflictData.userName,
        "user_image" : widget.conflictData.imageUrl
      };

      try {
        Conflict updatedConflict = await ConflictService.editConflict(context, userData);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conflict updated successfully'),
          ),
        );

        // passing the data to previous screen for updating
        widget.changeData( updatedConflict );

      } catch (error, stacktrace ) {
        debugPrint( error.toString() );
        debugPrint( stacktrace.toString() );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
          ),
        );
      }
    }
  }

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
  }

  Future<void> fetchDynamicLists() async {
    dynamicLists = await DynamicListService.fetchDynamicLists(context);

    setState(() {
      selectedRange = dynamicLists['range'].where( (range) => range['name'] == widget.conflictData.range ).first;
      selectedRound = dynamicLists['round'].where( (round) => round['name'] == widget.conflictData.round ).first;
      selectedBt = dynamicLists['beat'].where( (beat) => beat['name'] == widget.conflictData.bt ).first;
      selectedConflict = dynamicLists['conflict'].where( (conflict) => conflict['name'] == widget.conflictData.conflict ).first;
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
            icon: Icon(Icons.person_add),
            label: 'Add Forest',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Forest Data',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
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
                        var rounds = dynamicLists['round'].where( (round) => round['range_id'] == selectedRange!['id'] ).toList();
                        selectedRound = rounds.isNotEmpty ? rounds.first : {};
                        var beats = dynamicLists['beat'].where( (beat) => beat['round_id'] == selectedRound!['id'] ).toList();
                        selectedBt = beats.isNotEmpty ? beats.first : {};
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
                    // items: dynamicLists['round']!.map<DropdownMenuItem<Map<String, dynamic>>>(
                    (round) => DropdownMenuItem<Map<String, dynamic>>(
                        child: Text(round['name']),
                        value: round,
                      ),
                    )
                        .toList(),
                    onChanged: (Map<String, dynamic>? value) {
                      setState(() {
                        selectedRound = value;
                        var beats = dynamicLists['beat'].where( (beat) => beat['round_id'] == selectedRound!['id'] ).toList();
                        selectedBt = beats.isNotEmpty ? beats.first : {};
                        // selectedBt = dynamicLists['beat'].first;
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
                    // items: dynamicLists['beat']!.map<DropdownMenuItem<Map<String, dynamic>>>( (beat) => DropdownMenuItem<Map<String, dynamic>>(
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
                    items: dynamicLists['conflict']!.map<DropdownMenuItem<Map<String,dynamic>>>( (e) => DropdownMenuItem<Map<String, dynamic>>(
                      child: Text(e['name']),
                      value: e,
                    )).toList(),
                    onChanged: (Map<String, dynamic>? value) {
                      selectedConflict = value;
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
                    onPressed: editConflict,
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
