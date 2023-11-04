// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/common/models/user.dart';
import 'package:forestapp/contstant/constant.dart';
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/dynamic_list_service.dart';
import 'package:forestapp/utils/hive_service.dart';
import 'package:forestapp/utils/user_service.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:forestapp/common/models/geopoint.dart' as G;

import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/themeHelper.dart';

class AddForestData extends StatefulWidget {
  const AddForestData({super.key});

  @override
  _AddForestDataState createState() => _AddForestDataState();
}

class _AddForestDataState extends State<AddForestData> {
  final _formKey = GlobalKey<FormState>();

  final _villageNameController = TextEditingController();
  final _cNoController = TextEditingController();
  final _personNameController = TextEditingController();
  final _personAgeController = TextEditingController();
  final _personGenderController = TextEditingController();
  final _spCausingDeathController = TextEditingController();
  final _notesController = TextEditingController();

  Map<String, dynamic>? selectedRange;
  Map<String, dynamic>? selectedRound;
  Map<String, dynamic>? selectedBt;
  Map<String, dynamic>? selectedConflict;
  String? selectedVillage;

  // list of errors for validation
  bool conflictError = false;
  bool villageNameError = false;
  bool cnoError = false;
  bool nameError = false;
  bool ageError = false;
  bool genderError = false;
  bool spError = false;
  bool notesError = false;

  Color conflictFieldColor = Colors.black.withOpacity(0.1);

  File? _image;
  late String _userEmail;

  Map<dynamic, dynamic> dynamicLists = {};

  HiveService hiveService = HiveService();

  List<String> villages = [
    "Usaripar, Ramtek",
    "Kadbhikheda, Ramtek",
    "Sawra, Ramtek",
    "Kamtee, Ramtek",
    "Dongartal, Ramtek",
    "Zinzaria, Ramtek",
    "Khapa, Ramtek",
    "Sillari, Ramtek",
    "Pipariya, Ramtek",
    "Salai, Ramtek",
    "Chatgaon, Ramtek",
    "Hiwra, Ramtek",
    "Mundi, Ramtek",
    "Ghoti, Ramtek",
    "Sahapur, Ramtek",
    "Dahoda, Ramtek",
    "Tuyapar, Ramtek",
    "Jamuniya, Ramtek",
    "Patharai, Ramtek",
    "Ambazari, Ramtek",
    "Borda, Ramtek",
    "Sarakha, Ramtek",
    "Kirangisarra, Parseoni",
    "Kolitmara, Parseoni",
    "Surera, Parseoni",
    "Banera, Parseoni",
    "Narhar, Parseoni",
    "Dhawalpur, Parseoni",
    "Sawangi, Parseoni",
    "Ghatkukda, Parseoni",
    "Pardi, Parseoni",
    "Gargoti, Parseoni",
    "Saleghat, Parseoni",
    "Suwardhara, Parseoni",
    "Siladevi, Perseoni",
    "Chargaon, Perseoni",
    "Makardhokda, Perseoni",
    "Ambazari, Perseoni",
    "Ghatpendhri, Perseoni"
  ];

  @override
  void initState() {
    super.initState();
    fetchDynamicLists();
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString(SHARED_USER_EMAIL);
    setState(() {
      _userEmail = userEmail ?? '';
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

    // Validating the data
    if( !_formKey.currentState!.validate() ) {
      Navigator.of(context).pop();
      return;
    }

    try {
      // getting user
      String name, contactNumber, imageUrl;

      if( await hasConnection ) {
        final User? user = await UserService.getUser( context, _userEmail );
        name = user!.name;
        contactNumber = user.contactNumber;
        imageUrl = user.imageUrl;
      }
      else {
        // loading from sharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        name = (await prefs.getString(SHARED_USER_NAME))!;
        contactNumber = (await prefs.getString(SHARED_USER_CONTACT))!;
        imageUrl = (await prefs.getString(SHARED_USER_IMAGEURL))!;

      }

      // Get the current location
      final position = await Geolocator.getCurrentPosition();
      final location = G.GeoPoint(latitude: position.latitude, longitude: position.longitude);

      Conflict conflictData = Conflict(
        id: "",
        range: selectedRange!['id'],
        round: selectedRound!['id'],
        bt: selectedBt!['id'],
        village_name: selectedVillage!,
        cNoName: _cNoController.text,
        conflict: selectedConflict!['id'],
        person_name: _personNameController.text,
        person_age: _personAgeController.text,
        person_gender: _personGenderController.text,
        sp_causing_death: _spCausingDeathController.text,
        notes: _notesController.text,
        imageUrl: _image!.path.toString(),
        location: location,
        userName: name,
        userEmail: _userEmail,
        userContact: contactNumber,
        userImage: imageUrl,
      );

      bool success = false;
      // getting the image url
      if (await hasConnection) {
        // updating the data on firebase
        // Create a new document in the 'forestdata' collection
        success = await ConflictService.addConflict( context, conflictData, _image!.path.toString() );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading the page in Offline mode'),
          ),
        );

        // creating a folder for storing image and storing the image there
        final String fileName = _image!.path.split("/").last;

        if (Platform.isAndroid) {
          var androidInfo = await DeviceInfoPlugin().androidInfo;
          var release = androidInfo.version.release;

          if( int.parse(release) < 10 ) {
            var storagePermission = await Permission.storage.request();

            if( ! await storagePermission.isGranted ) {
              throw Exception('Storage permission not granted');
            }
          }
          else {
            var storagePermission = await Permission.manageExternalStorage;

            if( await storagePermission.isGranted ) {
              storagePermission.request();

              if( ! await storagePermission.isGranted ) {
                throw Exception('Storage permission not granted');
              }
            }
          }

          final storagePermission = await Permission.manageExternalStorage.request();
          if( storagePermission.isDenied || storagePermission.isRestricted ) {
            openAppSettings();
          }
        }

        Directory? directory = await getExternalStorageDirectory();
        String newPath = "";

        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/ConflictApp/data/.cachedImages";
        directory = Directory(newPath);

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        var file = File('${directory.path}/$fileName');
        await file.writeAsBytes(_image!.readAsBytesSync());

        // setting the image url as filepath
        conflictData.imageUrl = directory.path + "/" + fileName;

        hiveService.addBoxes<Conflict>([conflictData], "stored_conflicts");
        success = true;
      }

      // Hide the loading spinner
      Navigator.pop(context);

      if( success ) {
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
                },
              ),
            ],
          ),
        );
      }
      else {
        // Show an alert dialog indicating success
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Failure'),
            content: const Text('Failed To Upload Status'),
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

  Future<void> fetchDynamicLists() async {
    if( await hasConnection ) {
      dynamicLists = await DynamicListService.fetchDynamicLists(context);

      // storing into hiveCache
      hiveService.setBox( [dynamicLists], "dynamic_list");
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading the page in Offline mode'),
        ),
      );

      // loading from hive cache
      bool exists = await hiveService.isExists(boxName: 'dynamic_list');

      if( exists ) {
        final userData = await hiveService.getBoxes<Map<dynamic, dynamic>>('dynamic_list');
        Map<String, dynamic> items = Map<String, dynamic>.from( userData[0] );

        for( var key in items.keys ) {
          items[key] = items[key].map( (value) => Map<String,dynamic>.from( value) ).toList();
        }

        dynamicLists.addAll(items);
      }
    }

    dynamicLists = jsonDecode( jsonEncode(dynamicLists) );

    if( dynamicLists['range'].isEmpty ) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No Ranges Found, please Add a range first'),
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
      return;
    }

    if( dynamicLists['round'].isEmpty ) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No Rounds Found, please Add a round first'),
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
      return;
    }

    if( dynamicLists['beat'].isEmpty ) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No Beats Found, please Add a Beat first'),
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
      return;
    }

    if( dynamicLists['conflict'].isEmpty ) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No Status Found, please Add a Status first'),
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
      return;
    }

    setState(() {
      selectedRange = dynamicLists['range']!.first;
      selectedRound = dynamicLists['round']!.first;
      selectedBt = dynamicLists['beat']!.first;
      selectedConflict = dynamicLists['conflict']!.first;
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
                      value: selectedRange,
                      decoration: ThemeHelper().textInputDecoration('Range', 'Enter Range'),
                      items: dynamicLists['range'].map<DropdownMenuItem<Map<String,dynamic>>>( (range) => DropdownMenuItem<Map<String,dynamic>>(
                        value: range,
                        child: Text( range['name'] ),
                      ) ).toList(),
                      onChanged: (var value) {
                        setState(() {
                          selectedRange = value as Map<String, dynamic>;
                          List<dynamic> rounds = dynamicLists['round'].where( (round) => round['range_id'] == selectedRange!['id'] ).toList();
                          selectedRound = rounds.isEmpty ? {} : rounds.first;

                          if( rounds.isNotEmpty ) {
                            List<dynamic> beats = dynamicLists['beat'].where( (beat) => beat['round_id'] == selectedRound!['id'] ).toList();
                            selectedBt = beats.isEmpty ? {} : beats.first;
                          }
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
                      decoration: ThemeHelper().textInputDecoration('Round', 'Enter Round'),
                      value: selectedRound,
                      items: dynamicLists['round']!.where( (round) => round['range_id'] == selectedRange!['id'] ).map<DropdownMenuItem<Map<String,dynamic>>>(
                            (round) => DropdownMenuItem<Map<String,dynamic>>(
                              child: Text(round['name']),
                              value: round,
                            ),
                          )
                          .toList(),
                      onChanged: (Map<String,dynamic>? value) {
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
                      decoration: ThemeHelper().textInputDecoration('Beats', 'Enter Beats'),
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
                    DropdownButtonFormField<String>(
                      validator: ( String? newValue ) {
                        if( newValue?.isEmpty ?? true ) {
                          return "Please Select a Village";
                        }
                      },
                      decoration: ThemeHelper().textInputDecoration('Village Name', 'Select Village'),
                      value: selectedVillage,
                      items: villages.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text( e ),
                        )
                      ).toList(),
                      onChanged: (String? value) {
                        selectedVillage = value;
                      },
                    ),

                    // TextFormField(
                    //   controller: _villageNameController,
                    //   decoration: ThemeHelper().textInputDecoration(
                    //       'Village name', 'Enter Village name'),
                    // ),

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
                      "Status",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField(
                      validator: ( Map<String, dynamic>? newValue ) {
                        if( newValue == null ) {
                          return "Please Select a Status";
                        }
                      },
                      decoration: ThemeHelper()
                          .textInputDecoration('Conflict', 'Select Status')
                          .copyWith(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: conflictFieldColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                      items: dynamicLists['conflict'].map<DropdownMenuItem<Map<String, dynamic>>>(
                            (conflict) => DropdownMenuItem<Map<String, dynamic>>(
                              child: Text(conflict['name'].toString()),
                              value: conflict,
                            ),
                          ).toList(),
                      onChanged: (var value) {
                        print( value );
                        selectedConflict = value as Map<String, dynamic>;
                      },
                    ),
                    if (conflictError)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 10.0,
                        ),
                        child: Text(
                          "Please Select a valid Status",
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
                      validator: (String? value) {
                        if( value?.isEmpty ?? true ) {
                          return "Please Enter a Name";
                        }
                      },
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
                      validator: (String? value) {
                        if( value?.isEmpty ?? true ) {
                          return "Please Enter a Age";
                        }
                        else if ( int.tryParse(value!) == null ) {
                          return "Age must be a number!";
                        }
                      },
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
                      validator: (String? value) {
                        if( value?.isEmpty ?? true ) {
                          return "Please Enter a Gender";
                        }
                      },
                      decoration: ThemeHelper()
                          .textInputDecoration('person_gender', 'Enter Gender'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      "Sp causing death",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (String? value) {
                        if( value?.isEmpty ?? true ) {
                          return "Please Enter a SP Causing Death";
                        }
                      },
                      controller: _spCausingDeathController,
                      decoration: ThemeHelper().textInputDecoration(
                          'sp_causing_death', 'sp causing death'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      "Description",
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
