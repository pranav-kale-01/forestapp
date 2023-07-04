import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:forestapp/common/models/ConflictModel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  MapScreen({required this.latitude, required this.longitude});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late List<ConflictModel> _profileDataList = [];
  late MapZoomPanBehavior _zoomPanBehavior;
  late List<MapLatLng> _markers;
  static GlobalKey previewContainer = new GlobalKey();
  int fileCount = 0 ;

  bool showInfoDialog = false;
  int _ind = 0;

  takeScreenShot() async{
    try {
      RenderRepaintBoundary? boundary = previewContainer.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage();
      // final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final storagePermission = await Permission.manageExternalStorage;

      if( storagePermission.status != PermissionStatus.granted ) {
        storagePermission.request();

        if( storagePermission.status == PermissionStatus.denied || storagePermission.status == PermissionStatus.restricted ) {
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
    // final prefs = await SharedPreferences.getInstance();
    // final userEmail = prefs.getString('userEmail');
    setState(() {
      // _userEmail = userEmail ?? '';
    });
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot = await FirebaseFirestore.instance.collection('forestdata').get();
    final profileDataList = userSnapshot.docs
        .map((doc) => ConflictModel(
            id: doc.id,
            range: doc['range'],
            round: doc['round'],
            bt: doc['bt'],
            cNoName: doc['c_no_name'],
            conflict: doc['conflict'],
            notes: doc['notes'],
            person_age: doc['person_age'],
            imageUrl: doc['imageUrl'],
            userName: doc['user_name'],
            userEmail: doc['user_email'],
            person_gender: doc['person_gender'],
            pincodeName: doc['pincode_name'],
            sp_causing_death: doc['sp_causing_death'],
            village_name: doc['village_name'],
            person_name: doc['person_name'],
            datetime: doc['createdAt'] as Timestamp?,
            location: doc['location'] as GeoPoint,
            userContact: doc['user_contact'],
            userImage: doc['user_imageUrl'],
          ))
        .toList();
    setState(() {
      _profileDataList = profileDataList;

      _markers = profileDataList
          .map((profileData) => MapLatLng(
              profileData.location.latitude,
              profileData.location.longitude,

              // DateFormat('MMM d, yyyy h:mm a').format(widget.forestData.datetime!.toDate())
          )
        ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    if (_profileDataList.isEmpty) {
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
                              _ind = index;
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
                          _profileDataList[_ind].village_name,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Last Updated - " + DateFormat('MMM d, yyyy h:mm a').format(_profileDataList[_ind].datetime!.toDate()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Location - " + _profileDataList[_ind].location.latitude.toString() + "N, " + _profileDataList[_ind].location.latitude.toString() + "E",
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
    );
  }
}
