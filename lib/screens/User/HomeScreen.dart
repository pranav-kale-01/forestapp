import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/contstant/constant.dart';
import 'package:forestapp/screens/loginScreen.dart';
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/hive_service.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/home_screen_list_tile.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) changeIndex;
  final Function(Map<String,dynamic>) setConflict;
  final Function(bool) showNavBar;

  const HomeScreen(
      {super.key,
      required this.setConflict,
      required this.changeIndex,
      required this.showNavBar});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _userEmail;
  late List<Conflict> _profileDataList = [];
  HiveService hiveService = HiveService();
  ValueNotifier<int> dialogTrigger = ValueNotifier(0);
  Future<void>? _future;
  LatLng? _currentLocation;

  int _TotalConflictsCount = 0;
  bool isLoading = true;
  bool conflictUploaded = false;

  Map<String, int> conflictsCounter = {
    'cattle injured': 0,
    'cattle killed': 0,
    'humans injured': 0,
    'humans killed': 0,
    'crop damaged': 0,
  };

  late double _longitude;
  late double _latitude;
  late double _circleRadius ; // radius in meters, 50000=km

  StreamSubscription? connection;
  bool isOffline = false;
  bool userInRange = false;

  late LatLng _point;
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();

    fetchUserEmail();
    _future = init();
  }

  Future<void> init() async {
    if (Util.hasUserLocation == false) {
      await _getCurrentLocation();
      userInRange = await isPointInsideCircle(_currentLocation!);
      Util.hasUserLocation = true;
      dialogTrigger.value = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.showNavBar(true);
    });
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString(SHARED_USER_EMAIL);
    final double longitude = double.parse( prefs.getString(SHARED_USER_LONGITUDE)! );
    final double latitude = double.parse( prefs.getString(SHARED_USER_LATITUDE)! );
    final double radius = double.parse( prefs.getString(SHARED_USER_RADIUS)! );

    setState(() {
      _userEmail = userEmail ?? '';
      _latitude = latitude;
      _longitude = longitude;
      _circleRadius = radius;
    });
    await fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    try {
      _TotalConflictsCount = 0;
      conflictsCounter = {
        'cattle injured': 0,
        'cattle killed': 0,
        'humans injured': 0,
        'humans killed': 0,
        'crop damaged': 0,
      };

      // if the data is loaded from cache showing a bottom popup to user alerting
      // that the app is running in offline mode
      if (!(await hasConnection)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading the page in Offline mode'),
          ),
        );

        // also setting up a listener to trigger when the device is back online
        connection = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          // trigger only when user comes back online
          if (result != ConnectivityResult.none) {
            // uploading the data to server
            uploadStoredConflicts().then((uploaded) => {
              if( uploaded )
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      "Back Online! Uploading stored Conflicts",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )

            }).then((value) => fetchUserProfileData() );

            connection?.cancel();
          }
        });

        setState(() {
          isLoading = false;
          _profileDataList = [];
          _TotalConflictsCount = 0;
        });
      }
      else {
        // initializing the conflictCounter
        List<dynamic> conflictCounts = await ConflictService.getCounts(context, userEmail: _userEmail );

        for (Map<String, dynamic> conflict in conflictCounts.reversed) {
          _TotalConflictsCount += int.parse(conflict['count']);
          conflictsCounter[conflict['conflict_name'].toLowerCase()] =
              int.parse(conflict['count']);
        }

        List<Conflict> conflictList = [];

        if( !conflictUploaded ) {
          conflictUploaded = true;
          uploadStoredConflicts().then((uploaded) => {
            if( uploaded )
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    "Back Online! Uploading stored Conflicts",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              )
          }).then((value) => fetchUserProfileData() );
        }

        conflictList = await ConflictService.getRecentEntries(context, userEmail: _userEmail);

        setState(() {
          isLoading = false;
          _profileDataList = conflictList;
          _TotalConflictsCount = conflictList.length;
        });
      }


    }
    catch( e, s ) {
      print( e );
      print( s );
    }

  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to continue.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Request location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Location Permissions Denied'),
            content: Text('Please grant location permissions to continue.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Permissions Denied'),
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    return;
  }

  AlertDialog _isInside(BuildContext context) {
    return AlertDialog(
      title: const Text('You are outside the privileged area..'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Do you want to exit the app?'),
          Text( "Current : " + _point.latitude.toString() + ", " + _point.longitude.toString() ),
          Text( "Stored : " + _latitude.toString() + ", " + _longitude.toString() ),
          Text("Radius : " + ( _circleRadius / 1000 ).toString() +  "km" ),
          Text("Distance : " + ( _distance / 1000 ).round().toString() + "Km" ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.remove('userEmail');
            Util.hasUserLocation = false;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          },
          child: Text('Logout',
              style: TextStyle(
                color: Colors.red,
              )),
        ),
        TextButton(
          onPressed: () {
            exit(0);
          },
          child: Text('Yes'),
        ),
      ],
    );
  }

  Future<bool> isPointInsideCircle(LatLng point) async {
    // sending an API request to check
    // var request = http.MultipartRequest(
    //     'POST', Uri.parse('${baseUrl}/guard/is_guard_in_range'));
    // request.fields.addAll({
    //   'email': _userEmail,
    //   'latitude': point.latitude.toString(),
    //   'longitude': point.longitude.toString()
    // });
    //
    // http.StreamedResponse response = await request.send();
    // return response.statusCode == 200;

    double distance = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      _latitude,
      _longitude,
    );

    // showDialog(context: context, builder: (context) => AlertDialog( title: Text( distance.toString() ), ));
    // for debugging
    // print( point.latitude.toString() + "|" + point.longitude.toString() );
    // print( _latitude.toString() + "|" + _longitude.toString() );
    // print("distance is : " + distance.toString() );

    return (distance <= _circleRadius);
  }

  Future<bool> uploadStoredConflicts() async {
    // getting all the conflicts in stored_conflicts
    var storedConflicts = await hiveService.getBoxes('stored_conflicts');

    if( storedConflicts.length == 0 ) {
      return false;
    }

    for (Conflict conflict in storedConflicts) {
      await ConflictService.addConflict(context, conflict, conflict.imageUrl );
    }

    clearStoredConflicts();
    return true;
  }

  Future<void> clearStoredConflicts() async {
    await hiveService.deleteBox( 'stored_conflicts' );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Finding your current location...",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
          } else {
            if (_currentLocation != null && !userInRange) {
              return Container(
                child: ValueListenableBuilder(
                    valueListenable: dialogTrigger,
                    builder: (ctx, value, child) {
                      Future.delayed(const Duration(seconds: 0), () {
                        showDialog(
                            barrierDismissible: false,
                            context: ctx,
                            builder: (ctx) {
                              return _isInside(context);
                            });
                      });
                      return const SizedBox();
                    }),
              );
            } else if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              debugPrint(snapshot.stackTrace.toString());

              return Center(
                child: Text("Some error occured!"),
              );
            } else {
              // for debugging
              if( Util.showDebugDialog ) {
                Util.showDebugDialog = false;
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Debugging Info"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( "Current : " + _point.latitude.toString() + ", " + _point.longitude.toString() ),
                            Text( "Stored : " + _latitude.toString() + ", " + _longitude.toString() ),
                            Text("Radius : " +  ( _circleRadius / 1000 ).toString() +  "km" ),
                            Text("Distance : " + ( _distance / 1000 ).round().toString() + "Km" ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      )
                  );
                });
              }

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
                body: isLoading ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Loading Data.....",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )  : Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 15),
                            width: mediaQuery.size.width,
                            height: mediaQuery.size.height * 0.4,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.setConflict({});
                                          widget.changeIndex(2);
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            padding: const EdgeInsets.all(15),
                                            height:
                                                mediaQuery.size.height * 0.15,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 5),
                                                  )
                                                ]),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  "Total conflicts",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  _TotalConflictsCount
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.setConflict({"name": 'humans injured', "id": ""});
                                          widget.changeIndex(2);
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            padding: const EdgeInsets.all(15),
                                            height:
                                                mediaQuery.size.height * 0.15,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 5),
                                                  )
                                                ]),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  "Humans Injured",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  conflictsCounter[
                                                          'humans injured']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.setConflict({"name": 'humans killed', "id": ""});
                                          widget.changeIndex(2);
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            padding: const EdgeInsets.all(15),
                                            height:
                                                mediaQuery.size.height * 0.15,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 5),
                                                  )
                                                ]),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  "Humans Killed",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  conflictsCounter[
                                                          'humans killed']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.setConflict({"name": 'cattle injured', "id": ""});
                                          widget.changeIndex(2);
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            padding: const EdgeInsets.all(15),
                                            height:
                                                mediaQuery.size.height * 0.15,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 5),
                                                  )
                                                ]),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  "Cattles Injured",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  conflictsCounter[
                                                          'cattle injured']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.setConflict({"name": 'cattle killed', "id": ""});
                                          widget.changeIndex(2);
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            padding: const EdgeInsets.all(15),
                                            height:
                                                mediaQuery.size.height * 0.15,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 5),
                                                  )
                                                ]),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  "Cattles Killed",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  conflictsCounter[
                                                          'cattle killed']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.setConflict({"name": 'crop damaged', "id": ""});
                                          widget.changeIndex(2);
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            padding: const EdgeInsets.all(15),
                                            height:
                                                mediaQuery.size.height * 0.15,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 5),
                                                  )
                                                ]),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  "Crop Damaged",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  conflictsCounter[
                                                          'crop damaged']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: mediaQuery.size.height * 0.36),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              color: Colors.white,
                            ),
                            alignment: Alignment.bottomCenter,
                            width: mediaQuery.size.width,
                            height: mediaQuery.size.height * 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  width: mediaQuery.size.width,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 12.0),
                                  child: Text(
                                    "Recent",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _profileDataList.isEmpty ? Expanded(
                                  child: Center(
                                    child: Text("No data found"),
                                  ),
                                ) : SizedBox(
                                  height: mediaQuery.size.height * 0.37,
                                  child: RefreshIndicator(
                                    onRefresh: fetchUserProfileData,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        children: (_profileDataList.length >= 5
                                                ? _profileDataList.sublist(0, 5)
                                                : _profileDataList)
                                            .map(
                                              (forestData) =>
                                                  HomeScreenListTile(
                                                    isAdmin: false,
                                                forestData: forestData,
                                                changeIndex: widget.changeIndex,
                                                deleteData: (Conflict data) {
                                                  setState(() {
                                                    _profileDataList
                                                        .removeWhere(
                                                            (element) =>
                                                                element.id ==
                                                                data.id);
                                                  });
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              );
            }
          }
        });
  }
}
