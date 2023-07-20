import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
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
  final Function( String) setConflict;
  final Function(bool) showNavBar;

  const HomeScreen({
    super.key,
    required this.setConflict,
    required this.changeIndex,
    required this.showNavBar
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _userEmail;
  late List<Conflict> _profileDataList = [];
  HiveService hiveService = HiveService();
  double? _longitude;
  double? _latitude;
  late double _circleRadius ; // radius in meters, 50000=km
  ValueNotifier<int> dialogTrigger = ValueNotifier(0);
  Future<void>? _future;
  LatLng? _currentLocation;

  int _TotalConflictsCount = 0;

  Map<String, int> conflictsCounter = {
    'cattle injured' : 0,
    'cattle killed' : 0,
    'humans injured' : 0,
    'humans killed' : 0,
    'crop damaged' : 0,
  };

  StreamSubscription? connection;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();

    fetchUserEmail();
    _future = init();
  }

  Future<void> init() async {
    if( Util.hasUserLocation == false ) {
      await _getCurrentLocation();
      isPointInsideCircle( _currentLocation! );
      Util.hasUserLocation = true;
      dialogTrigger.value = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.showNavBar(true);
    });
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    final double longitude = double.parse( prefs.getString('longitude')! );
    final double latitude = double.parse( prefs.getString('latitude')! );
    final double radius = double.parse( prefs.getString('radius')! );
    print(prefs);

    setState(() {
      _userEmail = userEmail ?? '';
      _latitude = latitude;
      _longitude = longitude;
      _circleRadius = radius;
    });
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    _TotalConflictsCount = 0;
    final List<Conflict> conflictList  = await ConflictService.getData( userEmail: _userEmail );

    // if the data is loaded from cache showing a bottom popup to user alerting
    // that the app is running in offline mode
    if( !(await hasConnection) ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading the page in Offline mode'),
        ),
      );

      // also setting up a listener to trigger when the device is back online
      connection = Connectivity().onConnectivityChanged.listen((ConnectivityResult result ) {
        // trigger only when user comes back online
        if( result != ConnectivityResult.none ) {
          fetchUserProfileData().then((value) => {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  "Back Online! Uploading stored Conflicts",
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
            )
          });

          // uploading the data to server
          uploadStoredConflicts();

          // unsubscribing the subscription once executed
          connection?.cancel();
        }
      });
    }

    for( var item in conflictList ) {
      if( !conflictsCounter.containsKey(item.conflict) ) {
        conflictsCounter[item.conflict] = 0;
      }

      conflictsCounter[item.conflict] = conflictsCounter[item.conflict]! + 1;
    }

    setState(() {
      _profileDataList = conflictList;
      _TotalConflictsCount = conflictList.length;
    });
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
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            SharedPreferences prefs =
            await SharedPreferences.getInstance();
            prefs.remove('userEmail');
            Util.hasUserLocation = false;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          },
          child: Text('Logout',style: TextStyle(
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

  bool isPointInsideCircle(LatLng point) {
    if ( _longitude==null || _latitude==null ) {
      return false;
    }

    print( point.latitude.toString() + "|" + point.longitude.toString() );
    print( _latitude.toString() + "|" + _longitude.toString() );
    double distance = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      _latitude!,
      _longitude!,
    );

    // showDialog(context: context, builder: (context) => AlertDialog( title: Text( distance.toString() ), ));
    return (distance <= _circleRadius);
  }

  Future<void> uploadStoredConflicts() async {
    // getting all the conflicts in stored_conflicts
    var storedConflicts = await hiveService.getBoxes('stored_conflicts');

    for( Conflict conflict in storedConflicts ) {
      await ConflictService.addConflict( conflict );
    }

    // clearing the stored conflicts once they are uploaded
    hiveService.setBox([], 'store_conflicts');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return FutureBuilder(
        future: _future,
        builder: (context,snapshot) {
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
          }
          else {
            if (_currentLocation != null &&
                isPointInsideCircle(_currentLocation!) == false) {
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
            }
            else if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              debugPrint(snapshot.stackTrace.toString());
              return Center(
                child: Text("Some error occured!"),
              );
            }
            else {
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
                body: _profileDataList.isEmpty ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Loading Data.....",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ) : Stack(
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
                                    widget.setConflict( '' );
                                    widget.changeIndex( 2 );
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.all(15),
                                      height: mediaQuery.size.height * 0.15,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 5),
                                            )
                                          ]
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Total conflicts",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            _TotalConflictsCount.toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    widget.setConflict( 'humans injured' );
                                    widget.changeIndex( 2 );
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.all(15),
                                      height: mediaQuery.size.height * 0.15,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 5),
                                            )
                                          ]
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Humans Injured",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            conflictsCounter['humans injured'].toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    widget.setConflict( 'humans killed' );
                                    widget.changeIndex( 2 );
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.all(15),
                                      height: mediaQuery.size.height * 0.15,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 5),
                                            )
                                          ]
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Humans Killed",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            conflictsCounter['humans killed'].toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    widget.setConflict( 'cattle injured' );
                                    widget.changeIndex( 2 );
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.all(15),
                                      height: mediaQuery.size.height * 0.15,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 5),
                                            )
                                          ]
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Cattles Injured",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            conflictsCounter['cattle injured'].toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    widget.setConflict( 'cattle killed' );
                                    widget.changeIndex( 2 );
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.all(15),
                                      height: mediaQuery.size.height * 0.15,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 5),
                                            )
                                          ]
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Cattles Killed",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            conflictsCounter['cattle killed'].toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    widget.setConflict( 'crop damaged' );
                                    widget.changeIndex( 2 );
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric( horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.all(15),
                                      height: mediaQuery.size.height * 0.15,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 5),
                                            )
                                          ]
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Crop Damaged",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            conflictsCounter['crop damaged'].toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: mediaQuery.size.height * 0.36 ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric( vertical: 10.0, horizontal: 4.0),
                            child: Text(
                              "Recent",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: mediaQuery.size.height * 0.37,
                            child: RefreshIndicator(
                              onRefresh: fetchUserProfileData,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: (_profileDataList.length >= 5 ? _profileDataList.sublist(0,5) : _profileDataList).map((forestData) =>  HomeScreenListTile(
                                    forestData: forestData,
                                    changeIndex: widget.changeIndex,
                                    deleteData: (Conflict data) {
                                      setState(() {
                                        _profileDataList.removeWhere((element) => element.id == data.id );
                                      });
                                    },
                                  ),
                                  ).toList(),
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
        }
    );
  }
}
