import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class ForestMapScreen extends StatefulWidget {
  final Conflict conflictData;
  final BottomNavigationBar bottomNavigator;

  ForestMapScreen({
    required this.bottomNavigator,
    required this.conflictData
  });

  @override
  _ForestMapScreenState createState() => _ForestMapScreenState();
}

class _ForestMapScreenState extends State<ForestMapScreen> {
  static GlobalKey previewContainer = new GlobalKey();

  late final BottomNavigationBar _bottomNavBar;
  late MapZoomPanBehavior _zoomPanBehavior;
  late List<MapLatLng> _markers;
  late double _zoomLevel;

  int fileCount = 0 ;
  bool showInfoDialog = false;

  @override
  void initState() {
    super.initState();

    _markers = [
      MapLatLng(widget.conflictData.location.latitude, widget.conflictData.location.longitude),
    ];

    _zoomLevel = calculateZoomLevel(_markers);
    _zoomPanBehavior = MapZoomPanBehavior(zoomLevel: _zoomLevel);

    if (_markers.isNotEmpty) {
      // Set zoom level based on the marker location
      _zoomPanBehavior.zoomLevel = 15;
      _zoomPanBehavior.focalLatLng = _markers.first;
    }

    _bottomNavBar = BottomNavigationBar(
        items: widget.bottomNavigator.items,
        currentIndex: 2,
        onTap: (index) {
          Navigator.of(context).pop();
          widget.bottomNavigator.onTap!( index );
        },
        selectedItemColor: Colors.green,
    );
  }

  takeScreenShot() async {
    try {
      RenderRepaintBoundary? boundary = previewContainer.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage();
      // final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

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

      var directory = await getExternalStorageDirectory();

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
      newPath = newPath + "/ConflictApp/map";
      directory = Directory(newPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      var imgFile = File('${directory.path}/screenshot.png');
      var fileName;

      while (await imgFile.exists()) {
        fileCount++;
        fileName = 'screenshot($fileCount).png';
        imgFile = File('${directory.path}/$fileName');
      }

      imgFile.writeAsBytes(pngBytes);

      // show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image saved to folder conflictApp/map',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            onPressed: () async {
              try {
                //Use the path to launch the directory with the native file explorer
                await OpenFilex.open('${directory?.path}/$fileName');
              }
              catch( e ) {
                // show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to export Image: $e'),
                    duration: const Duration(seconds: 5),
                  ),
                );
              }

            },
            label: "Open",
            textColor: Colors.black,
          ),
        ),

      );
    }
    catch( e ) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export Image: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

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
          'Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                takeScreenShot();
              },
              icon: Icon(
                  Icons.download_sharp
              )
          )
        ],
      ),
      body: RepaintBoundary(
        key: previewContainer,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  showInfoDialog = false;
                });
              },
              child: SfMaps(
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
                            setState(() {
                              showInfoDialog = true;
                            });
                          },
                        ),
                      );
                    },
                    initialMarkersCount: _markers.length,
                  ),
                ],
              ),
            ),
            if( showInfoDialog )
              Container(
                  width: mediaQuery.width * 0.96,
                  margin: const EdgeInsets.symmetric( vertical: 8.0, ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular( 15.0, ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade500,
                          offset: const Offset( 1, 4),
                          blurRadius: 2,
                        )
                      ]
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.conflictData.village_name,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Last Updated - " + DateFormat('MMM d, yyyy h:mm a').format(widget.conflictData.datetime!.toDate()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Location - " + widget.conflictData.location.latitude.toString() + "N, " + widget.conflictData.location.latitude.toString() + "E",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
              )
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
