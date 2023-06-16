// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/themeHelper.dart';
import 'homeUser.dart';

class ProfileData {
  final String name;
  final String email;
  final String contactNumber;
  final String imageUrl;

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
  final _formKey = GlobalKey<FormState>();

  final _villageNameController = TextEditingController();
  final _cNoController = TextEditingController();
  final _pincodeNameController = TextEditingController();
  final _personNameController = TextEditingController();
  final _personAgeController = TextEditingController();
  final _personGenderController = TextEditingController();
  final _spCausingDeathController = TextEditingController();
  final _notesController = TextEditingController();

  String? selectedRange;
  String? selectedRound;
  String? selectedBt;
  String? selectedConflict;

  // list of errors for validation
  bool conflictError = false;
  bool villageNameError = false;
  bool cnoError = false;
  bool pincodeError = false;
  bool nameError = false;
  bool ageError = false;
  bool genderError = false;
  bool spError = false;
  bool notesError = false;

  Color conflictFieldColor = Colors.black.withOpacity(0.1);

  File? _image;
  late String _userEmail;
  late ProfileData _profileData;
  
  Map<String, List<dynamic>> dynamicLists = {};

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    fetchDynamicLists();
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  // Future<void> _getCurrentLocation() async {
  //   final position = await Geolocator.getCurrentPosition();
  //   setState(() {
  //     _currentLocation =
  //         'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  //   });
  // }

  void _onSubmitPressed() async {
    // Validate the form

    // if selected conflict is None then asking the user to select any other conflict
    if( selectedConflict == "None" ) {
      conflictError = true;

      setState(() {
        conflictFieldColor = Colors.red;
      });
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
        'imageUrl': imageUrl,
        'location': location,
        'user_name': _profileData.name,
        'user_email': _profileData.email,
        'user_contact': _profileData.contactNumber,
        'user_imageUrl': _profileData.imageUrl,
        'createdAt': DateTime.now(),
      };

      await docRef.set(data);

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
    } catch (error, stacktrace ) {
      debugPrint( error.toString() );
      debugPrint( stacktrace.toString() );

      // Hide the loading spinner
      Navigator.pop(context);

      // Show an alert dialog indicating failure
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload data. Error : ${error}'),
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
      selectedRange = dynamicLists['range']!.first.toString();
      selectedRound = dynamicLists['round']!.first.toString();
      selectedBt = dynamicLists['beat']!.first.toString();
      selectedConflict = "None";
    });
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
        'Pench MH',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    body: dynamicLists.isEmpty ? Center(
      child: CircularProgressIndicator(),
      ) : Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 15,
              ),
              Text(
                "Add Forest Data",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),

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
                items: dynamicLists['range']!.map( (e) => DropdownMenuItem(
                  child: Text(e.toString()),
                  value: e.toString(),
                ),
                ).toList(),
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
                items: dynamicLists['round']!.map( (e) => DropdownMenuItem(
                  child: Text(e.toString()),
                  value: e.toString(),
                ),
                ).toList(),
                onChanged: (Object? value) {
                  selectedRound = value.toString();
                },
              ),
              const SizedBox(
                height: 10,
              ),

              Text(
                "Bits",
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
                    'Beats', 'Enter Beats'
                ),
                value: selectedBt,
                items: dynamicLists['beat']!.map( (e) => DropdownMenuItem(
                  child: Text(e.toString()),
                  value: e.toString(),
                ),
                ).toList(),
                onChanged: (Object? value) {
                  selectedBt = value.toString();
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
                ).copyWith(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: conflictFieldColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                value: selectedConflict,
                items: dynamicLists['conflict']!.map( (e) => DropdownMenuItem(
                  child: Text(e.toString()),
                  value: e.toString(),
                ),
                ).toList(),
                onChanged: (Object? value) {
                  if( value != "None" ) {
                    setState(() {
                      conflictError = false;
                      conflictFieldColor = Colors.black.withOpacity(0.1);
                    });
                  }

                  selectedConflict = value.toString();
                },
              ),
              if( conflictError )
                Padding(
                  padding: const EdgeInsets.symmetric( vertical: 5.0, horizontal: 10.0, ),
                  child: Text(
                    "Please Select a valid conflict",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
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

              const SizedBox(
                height: 20,
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
                onPressed: () => _onSubmitPressed(),
                child: Padding(
                  padding: const EdgeInsets.symmetric( vertical: 18.0),
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
