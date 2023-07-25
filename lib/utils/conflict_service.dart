import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/common/models/geopoint.dart';
import 'package:forestapp/utils/hive_service.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/models/timestamp.dart';

class ConflictService {
  static HiveService hiveService = HiveService();

  static Future<List<dynamic>> getCounts( BuildContext context) async  {
    var request = http.Request('GET', Uri.parse('${baseUrl}/admin/get_counts'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode( await response.stream.bytesToString());
      return jsonResponse;
    }
    else {
      print(response.reasonPhrase);
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload data. Error : ${response.reasonPhrase}'),
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
      return [];
    }
  }

  static Future<List<Conflict>> getRecentEntries( BuildContext context, { String userEmail = "" } ) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/get_recent_entries'));
    request.fields.addAll({
      'email': userEmail,
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode( await response.stream.bytesToString());
      return jsonResponse.map((doc) => Conflict(
            id: doc['id'],
            range: doc['range_name'],
            round: doc['round_name'],
            bt: doc['beat_name'],
            cNoName: doc['cn_sr_name'],
            conflict: doc['conflict_name'],
            notes: doc['notes'],
            person_age: doc['age'],
            imageUrl: doc['photo'],
            userName: doc['guard_name'],
            userEmail: doc['email'],
            person_name: doc['name'],
            person_gender: doc['gender'],
            pincodeName: doc['pincode'],
            sp_causing_death: doc['sp_causing_death'],
            village_name: doc['village_name'],
            datetime: TimeStamp.fromDate( DateTime.parse(doc['created_at']) ),
            location: GeoPoint(
                latitude: double.parse( doc['latitude'] ),
                longitude: double.parse( doc['longitude'] )
            ),
            userContact: doc['guard_contact'],
            userImage: doc['photo']
        )
      ).toList();
    }
    else {
      print(response.reasonPhrase);
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text(response.reasonPhrase.toString() ),
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
      return [];
    }
  }

  static Future<List<Conflict>> getData(BuildContext context, { getLocalData = false, userEmail = "" }) async {
    List<Conflict> _conflictList = [];

    if ( !(await hasConnection ) || getLocalData ) {
      bool exists = await hiveService.isExists(boxName: "ConflictTable");

      if (exists) {
        _conflictList = await hiveService.getBoxes<Conflict>("ConflictTable");
      }
    } else {
      // calling the Api to get counts
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/get_conflicts'));
      request.fields.addAll({
        'email': userEmail
      });

      http.StreamedResponse response = await request.send();
      List<dynamic> jsonResult;

      if (response.statusCode == 200) {
        jsonResult = jsonDecode( await response.stream.bytesToString() );
      }
      else {
        print(response.reasonPhrase);
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to upload data. Error : ${response.reasonPhrase}'),
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
        return [];
      }

      jsonResult.map((doc) {
        Conflict conflict = Conflict(
            id: doc['id'],
            range: doc['range_name'],
            round: doc['round_name'],
            bt: doc['beat_name'],
            cNoName: doc['cn_sr_name'],
            conflict: doc['conflict_name'],
            notes: doc['notes'],
            person_age: doc['age'],
            imageUrl: doc['photo'],
            userName: doc['guard_name'],
            userEmail: doc['email'],
            person_name: doc['name'],
            person_gender: doc['gender'],
            pincodeName: doc['pincode'],
            sp_causing_death: doc['sp_causing_death'],
            village_name: doc['village_name'],
            datetime: TimeStamp.fromDate( DateTime.parse(doc['created_at']) ),
            location: GeoPoint(
                latitude: double.parse( doc['latitude'] ),
                longitude: double.parse( doc['longitude'] )
            ),
            userContact: doc['guard_contact'],
            userImage: doc['photo']
        );
        _conflictList.add(conflict);
      }).toList();

      await hiveService.setBox(_conflictList, "conflictTable");
    }

    return _conflictList;
  }

  static Future<bool> addConflict( BuildContext context, Conflict conflict, String photoUrl ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}guard/add_conflict'));

      request.fields.addAll({
        'email': conflict.userEmail,
        'range_id': conflict.range,
        'round_id': conflict.round,
        'beat_id': conflict.bt,
        'village_name': conflict.village_name,
        'cn_sr_name': conflict.cNoName,
        'pincode': conflict.pincodeName,
        'conflict_id': conflict.conflict,
        'name': conflict.userName,
        'age': conflict.person_age,
        'gender': conflict.person_gender,
        'sp_causing_death': conflict.sp_causing_death,
        'notes': conflict.notes,
        'latitude': conflict.location.latitude.toString(),
        'longitude':  conflict.location.longitude.toString(),
      });
      request.files.add(await http.MultipartFile.fromPath('photo', photoUrl ) );
      http.StreamedResponse response = await request.send();

      if( response.statusCode != 200 ) {
        print(response.reasonPhrase);
        print( await response.stream.bytesToString( ) );
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to upload data. Error : ${response.reasonPhrase}'),
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

      return response.statusCode == 200;
    }
    catch( e, s ) {
      print( e );
      print( s );

      return false;
    }



  }

  static Future<Conflict> editConflict( BuildContext context, Map<String, dynamic> data ) async {
    // sending a api request to update Conflict
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}/guard/edit_conflict'));
    request.fields.addAll({
      'id': data['id'],
      'email': data['email'],
      'range_id': data['range']['id'],
      'round_id': data['round']['id'],
      'beat_id': data['beat']['id'],
      'village_name': data['village_name'],
      'cn_sr_name': data['cn_sr_name'],
      'pincode': data['pincode'],
      'conflict_id': data['conflict']['id'],
      'name': data['name'],
      'age': data['age'],
      'gender': data['gender'],
      'sp_causing_death': data['sp_causing_death'],
      'notes': data['notes'],
      'photo': data['photo'],
      'latitude': data['latitude'].toString(),
      'longitude': data['longitude'].toString(),
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload data. Error : ${response.reasonPhrase}'),
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

    return Conflict(
        id: data['id'],
        range: data["range"]['name'],
        round: data["round"]['name'],
        bt: data['beat']['name'],
        village_name: data["village_name"],
        cNoName: data["cn_sr_name"],
        conflict: data["conflict"]['name'],
        person_name: data["name"],
        pincodeName: data["pincode"],
        person_age: data["age"],
        person_gender: data["gender"],
        sp_causing_death: data["sp_causing_death"],
        notes: data["notes"],
        datetime: TimeStamp.fromDate( DateTime.now() ),
        imageUrl: data['photo'],
        userName: data["user_name"],
        userEmail: data["email"],
        location: GeoPoint( latitude: data['latitude'], longitude: data['longitude']) ,
        userContact: data["contact"],
        userImage: data["user_image"],
    );
  }

  static Future<bool> deleteConflict( BuildContext context, String conflictId ) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}guard/delete_conflict'));

    request.fields.addAll({
      'id': conflictId
    });

    http.StreamedResponse response = await request.send();
    print( await response.stream.bytesToString( ) );

    if( response.statusCode != 200 ) {
      print( await response.stream.bytesToString() );
      print( response.reasonPhrase.toString() );
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload data. Error : ${response.reasonPhrase}'),
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

    return response.statusCode == 200;
  }

  static Future<void> exportToExcel( List<dynamic> searchResult, BuildContext context ) async {
    Directory? directory;
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // add header row
      sheet.appendRow([
        'Range',
        'Round',
        'Beat',
        'village Name'
            'CNo/S.No Name',
        'Pincode Name',
        'conflict',
        'Name',
        'Age',
        'gender',
        'SP Causing Death',
        'notes',
        'Username'
            'User Email',
        'User Contact',
        'location',
        'Created At',
      ]);

      // add data rows
      searchResult.forEach((data) {
        sheet.appendRow([
          data.range,
          data.round,
          data.bt,
          data.village_name,
          data.cNoName,
          data.pincodeName,
          data.conflict,
          data.person_name,
          data.person_age,
          data.person_gender,
          data.sp_causing_death,
          data.notes,
          data.userName,
          data.userEmail,
          data.userContact,
          data.location,
          data.datetime,
        ]);
      });

      // save the Excel file
      final fileBytes = excel.encode();
      int fileCount = 0;

      String fileName = 'forest_data.xlsx';

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

      directory = await getExternalStorageDirectory();

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
      newPath = newPath + "/ConflictApp/data";
      directory = Directory(newPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      var file = File('${directory.path}/$fileName');

      while (await file.exists()) {
        fileCount++;
        fileName = 'forest_data($fileCount).xls';
        file = File('${directory.path}/$fileName');
      }

      await file.writeAsBytes(fileBytes!);

      // show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Excel file saved to folder conflictApp/data',
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
              //Use the path to launch the directory with the native file explorer
              await OpenFilex.open('${directory?.path}/$fileName');
            },
            label: "Open",
            textColor: Colors.black,
          ),
        ),
      );
    } catch (e) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export to Excel failed: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
