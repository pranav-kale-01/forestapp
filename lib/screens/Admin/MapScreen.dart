import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:math' as math;

import 'ForestDataScreen.dart';

class ProfileData {
  final String title;
  final String description;
  final String imageUrl;
  final String userName;
  final String userEmail;
  final Timestamp? datetime;
  final GeoPoint location;

  ProfileData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.userEmail,
    this.datetime,
    required this.location,
  });
}

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  MapScreen({required this.latitude, required this.longitude});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late String _userEmail;
  late List<ProfileData> _profileDataList = [];

  late int _count;
  late int _countUser;

  late MapZoomPanBehavior _zoomPanBehavior;
  late List<MapLatLng> _markers;

  @override
  void initState() {
    super.initState();

    fetchUserProfileData();
    _zoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true, // enable or disable double tap zooming
      enablePinching: true, // enable or disable pinching to zoom
      enablePanning: true, // enable or disable panning
    );
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    setState(() {
      _userEmail = userEmail ?? '';
    });
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('forestdata').get();
    final profileDataList = userSnapshot.docs
        .map((doc) => ProfileData(
              imageUrl: doc['imageUrl'],
              title: doc['title'],
              description: doc['description'],
              userName: doc['user_name'],
              userEmail: doc['user_email'],
              datetime: doc['createdAt'] as Timestamp?,
              location: doc['location'] as GeoPoint,
            ))
        .toList();
    setState(() {
      _profileDataList = profileDataList;

      _markers = profileDataList
          .map((profileData) => MapLatLng(
              profileData.location.latitude, profileData.location.longitude))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_profileDataList.isEmpty) {
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
          title: Text("Map"),
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No Data Found.....",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 5,
              ),
              CircularProgressIndicator()
            ],
          ),
        ),
      );
    }
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
        title: Text("Map"),
      ),
      body: SfMaps(
        layers: [
          MapTileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            initialZoomLevel: 13,
            initialFocalLatLng: MapLatLng(21.5549701, 79.1735154),
            zoomPanBehavior: _zoomPanBehavior,
            markerBuilder: (BuildContext context, int index) {
              return MapMarker(
                latitude: _markers[index].latitude,
                longitude: _markers[index].longitude,
                child: GestureDetector(
                  child: Icon(
                    Icons.location_on,
                    size: 50,
                    color: Colors.red,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          'Tiger: ${_profileDataList[index].title}, Added by: ${_profileDataList[index].userName}',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            initialMarkersCount: _markers.length,
          ),
        ],
      ),
    );
  }
}
