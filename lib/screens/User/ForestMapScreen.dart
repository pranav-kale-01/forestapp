import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class ForestMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String userName;
  final String conflictName;

  ForestMapScreen(
      {required this.latitude,
      required this.longitude,
      required this.userName,
      required this.conflictName});

  @override
  _ForestMapScreenState createState() => _ForestMapScreenState();
}

class _ForestMapScreenState extends State<ForestMapScreen> {
  static GlobalKey previewContainer = new GlobalKey();

  late MapZoomPanBehavior _zoomPanBehavior;
  late List<MapLatLng> _markers;
  late double _zoomLevel;
  int fileCount = 0 ;
  bool dialogOpen = false;


  takeScreenShot() async {
    try {
      RenderRepaintBoundary? boundary = previewContainer.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage();
      // final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final storagePermission = await Permission.manageExternalStorage.request();
      if( storagePermission.isDenied || storagePermission.isRestricted ) {
        openAppSettings();
      }

      var directory = await getExternalStorageDirectory();

      String newPath = "";
      print(directory);

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

  @override
  void initState() {
    super.initState();

    _markers = [
      MapLatLng(widget.latitude, widget.longitude),
    ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        title: Text(
          widget.userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric( horizontal: 12.0),
            child: IconButton(
                onPressed: () {
                  takeScreenShot();
                },
                icon: Icon(
                    Icons.download_sharp
                )
            ),
          )
        ],
      ),
      body: RepaintBoundary(
        key: previewContainer,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            GestureDetector(
              onTap: () {
                if( dialogOpen ) {
                  setState(() {
                    dialogOpen = false;
                  });

                  Navigator.of(context).pop();
                }
              },
              child: SfMaps(
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
                            setState(() {
                              dialogOpen = true;
                            });

                            showBottomSheet(
                              context: context,
                              builder: (_) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Conflict: ${widget.conflictName}, Added by: ${widget.userName}',
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
            ),
            if( dialogOpen )
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Conflict: ${widget.conflictName}, Added by: ${widget.userName}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
