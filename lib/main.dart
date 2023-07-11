import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';

import 'package:forestapp/screens/splashScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Location _location = Location();

  final Color _primaryColor = HexColor('#54fe7f');

  final Color _accentColor = HexColor('#16DFAF');
  
  final Color _backgroundColor = HexColor('#F1CB44');
  
  final Color _onBackgroundColor = HexColor('#77916A');

  @override
  void initState() {
    super.initState();

    checkGps();
  }

  Future<void> checkGps() async{
    // final location = Location();
    Geolocator.isLocationServiceEnabled().then((isGpsOn){
        if(isGpsOn){
          requestLocationPermission();
        }else{
          turnOnGps();
        }
    });
  }

  void turnOnGps(){
    final AndroidIntent intent = AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS');
    intent.launch();
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: Colors.grey.shade100,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
            .copyWith(
            secondary: _accentColor,
            background: _backgroundColor,
            primaryContainer: _backgroundColor,
            secondaryContainer: _onBackgroundColor,
        ),
      ),
      home: const SplashScreen(title: 'Flutter Login UI'),
    );
  }
}
