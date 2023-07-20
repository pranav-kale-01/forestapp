import 'package:flutter/material.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/utils/conflict_service.dart';
import 'package:forestapp/utils/utils.dart';

import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:math' as math;

class ForestMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String userName;
  final String tigerName;

  ForestMapScreen(
      {required this.latitude,
      required this.longitude,
      required this.userName,
      required this.tigerName});

  @override
  _ForestMapScreenState createState() => _ForestMapScreenState();
}

class _ForestMapScreenState extends State<ForestMapScreen> {

  late List<Conflict> _profileDataList = [];

  late MapZoomPanBehavior _zoomPanBehavior;
  late List<MapLatLng> _markers;
  late double _zoomLevel;

  @override
  void initState() {
    super.initState();

    _markers = [
      MapLatLng(widget.latitude, widget.longitude),
    ];

    fetchUserProfileData();

    _zoomLevel = calculateZoomLevel(_markers);
    _zoomPanBehavior = MapZoomPanBehavior(zoomLevel: _zoomLevel);

    if (_markers.isNotEmpty) {
      // Set zoom level based on the marker location
      _zoomPanBehavior.zoomLevel = 15;
      _zoomPanBehavior.focalLatLng = _markers.first;
    }
  }

  double calculateZoomLevel(List<MapLatLng> markers) {
    if (markers.isEmpty) {
      return 1;
    }

    double maxLat = -90;
    double minLat = 90;
    double maxLon = -180;
    double minLon = 180;

    for (MapLatLng marker in markers) {
      maxLat = math.max(maxLat, marker.latitude);
      minLat = math.min(minLat, marker.latitude);
      maxLon = math.max(maxLon, marker.longitude);
      minLon = math.min(minLon, marker.longitude);
    }

    double deltaLat = maxLat - minLat;
    double deltaLon = maxLon - minLon;
    double zoomLat = math.log(360 / deltaLat) / math.ln2;
    double zoomLon = math.log(360 / deltaLon) / math.ln2;
    double zoom = math.min(zoomLat, zoomLon);

    return zoom;
  }

  Future<void> fetchUserEmail() async {
    // final prefs = await SharedPreferences.getInstance();
    // final userEmail = prefs.getString('userEmail');
    setState(() {
      // _userEmail = userEmail ?? '';
    });
  }

  Future<void> fetchUserProfileData() async {
    final profileDataList = await ConflictService.getData();

    // if the data is loaded from cache showing a bottom popup to user alerting
    // that the app is running in offline mode
    if( !(await hasConnection) ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading the page in Offline mode'),
        ),
      );
    }

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
      return const Center(child: CircularProgressIndicator());
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
        title: Text(widget.tigerName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SfMaps(
        layers: [
          MapTileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                          'Tiger: ${widget.tigerName}, Added by: ${widget.userName}',
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
