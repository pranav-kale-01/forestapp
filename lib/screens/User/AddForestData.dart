// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forestapp/common/models/geopoint.dart' as G;
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/hive_service.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/models/timestamp.dart';
import '../../common/themeHelper.dart';

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

  Map<String, dynamic>? selectedRange;
  Map<String, dynamic>? selectedRound;
  Map<String, dynamic>? selectedBt;
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

  Map<dynamic, dynamic> dynamicLists = {};

  HiveService hiveService = HiveService();

  @override
  void initState() {
    super.initState();
    fetchDynamicLists();
    fetchUserEmail();
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
    // if the data is loaded from cache showing a bottom popup to user alerting
    // that the app is running in offline mode
    if (!(await hasConnection)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading the page in Offline mode'),
        ),
      );
    }

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

  void _onSubmitPressed() async {
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
      // Get the current location
      final position = await Geolocator.getCurrentPosition();
      final location = G.GeoPoint(
          latitude: position.latitude, longitude: position.longitude);
      final currentDateTime = Timestamp.fromDate(DateTime.now());

      Conflict data = Conflict(
        id: "",
        range: selectedRange!['name'],
        round: selectedRound!['name'],
        bt: selectedBt!['name'],
        village_name: _villageNameController.text,
        cNoName: _cNoController.text,
        conflict: selectedConflict!,
        person_name: _personNameController.text,
        pincodeName: _pincodeNameController.text,
        person_age: _personAgeController.text,
        person_gender: _personGenderController.text,
        sp_causing_death: _spCausingDeathController.text,
        notes: _notesController.text,
        imageUrl: "",
        location: location,
        userName: _profileData.name,
        userEmail: _profileData.email,
        userContact: _profileData.contactNumber,
        userImage: _profileData.imageUrl,
        datetime: TimeStamp(
            seconds: currentDateTime.seconds,
            nanoseconds: currentDateTime.nanoseconds),
      );

      // getting the image url
      if (await hasConnection) {
        // updating the data on firebase
        // Create a new document in the 'forestdata' collection
        await ConflictService.addConflict(data, image: _image);
      } else {
        // if the device does not have internet connection adding caching the
        // object to upload later

        // creating a folder for storing image and storing the image there
        var baseDir = await getApplicationDocumentsDirectory();

        final String fileName = _image!.path.split("/").last;
        data.imageUrl = baseDir.path + "/" + fileName;

        File image = File(data.imageUrl);
        image.writeAsBytesSync(_image!.readAsBytesSync());

        hiveService.addBoxes<Conflict>([data], "stored_conflicts");
      }

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
                Navigator.of(context).pop();

                // Navigator.of(context).pushAndRemoveUntil(
                //     MaterialPageRoute(
                //       builder: (context) => const HomeUser(
                //         title: 'title',
                //       ),
                //     ),
                //     (route) => false);
              },
            ),
          ],
        ),
      );
    } catch (error, stacktrace) {
      debugPrint(error.toString());
      debugPrint(stacktrace.toString());

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
                Navigator.of(context).pop();
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
    // if( await hasConnection ) {
    if( true ) {
      final userSnapshot = await FirebaseFirestore.instance.collection('dynamic_lists').get();
      final userData = userSnapshot.docs;

      for (var item in userData) {
        dynamicLists[item.id] = item['values'];
      }

      // storing into hiveCache
      hiveService.setBox( [dynamicLists], "dynamic_list");

      // dynamicLists['range'] = dynamicLists['range'].toSet().toList();
    }
    else {
      // loading from hive cache
      bool exists = await hiveService.isExists(boxName: 'dynamic_list');
      if( exists ) {
        final userData = (await hiveService.getBoxes<Map<dynamic, dynamic>>('dynamic_list'));
        dynamicLists = userData[0] ;
      }
    }
    // setting the dynamic list for conflict with value none
    dynamicLists['conflict']?.add('None');

    setState(() {
      selectedRange = dynamicLists['range']!.first;
      selectedRound = dynamicLists['round']!.first;
      selectedBt = dynamicLists['beat']!.first;
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
              )),
        ),
        title: const Text(
          'Pench MH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: dynamicLists.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Add Forest Data",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      decoration: ThemeHelper().textInputDecoration(
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
                      decoration: ThemeHelper().textInputDecoration(
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
                      decoration: ThemeHelper().textInputDecoration(
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
                      decoration: ThemeHelper()
                          .textInputDecoration('Conflict', 'Select Conflict')
                          .copyWith(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: conflictFieldColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                      value: selectedConflict,
                      items: dynamicLists['conflict']!.map<DropdownMenuItem<String>>(
                            (conflict) => DropdownMenuItem<String>(
                              child: Text(conflict),
                              value: conflict,
                            ),
                          ).toList(),
                      onChanged: (Object? value) {
                        // if( value != "None" ) {
                        //   setState(() {
                        //     conflictError = false;
                        //     conflictFieldColor = Colors.black.withOpacity(0.1);
                        //   });
                        // }

                        selectedConflict = value.toString();
                      },
                    ),
                    if (conflictError)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 10.0,
                        ),
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
                          .textInputDecoration('person_name', 'Enter name'),
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
                          .textInputDecoration('person_age', 'Enter Age'),
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
                          .textInputDecoration('person_gender', 'Enter Gender'),
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
                      decoration: ThemeHelper().textInputDecoration(
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
                        decoration:
                            ThemeHelper().textInputDecoration('notes', 'Notes'),
                        maxLines: null,
                        keyboardType: TextInputType.multiline),
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
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green.shade400),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ))),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          child: Text(
                              _image == null ? 'Add Photo' : 'Change Photo')),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green.shade400),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ))),
                      onPressed: () => _onSubmitPressed(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
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
