import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/common/models/geopoint.dart' as G;
import 'package:forestapp/utils/hive_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forestapp/utils/utils.dart';
import 'package:http/http.dart' as http;

import '../common/models/timestamp.dart';

class ConflictService {
  static HiveService hiveService = HiveService();


  static Future<List<dynamic>> getCounts() async  {
    var request = http.Request('GET', Uri.parse('${baseUrl}/admin/get_counts'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode( await response.stream.bytesToString());
      return jsonResponse;
    }
    else {
      print(response.reasonPhrase);
      return [];
    }
  }

  static Future<List<Conflict>> getData({ getLocalData = false, userEmail = "" }) async {
    List<Conflict> _conflictList = [];

    if ( !(await hasConnection ) || getLocalData ) {
      bool exists = await hiveService.isExists(boxName: "ConflictTable");

      print("Exists - " + exists.toString() );
      if (exists) {
        print("getting stored list");
        _conflictList = await hiveService.getBoxes<Conflict>("ConflictTable");
      }
    } else {
      print("getting list from API");

      List<dynamic> jsonResult;

      if( userEmail.isEmpty ) {
        // calling the Api to get counts
        var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/get_recent_entries'));
        request.fields.addAll({
          'email': userEmail
        });

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          jsonResult = jsonDecode( await response.stream.bytesToString() );
        }
        else {
          print(response.reasonPhrase);
          return [];
        }

        // result = await FirebaseFirestore.instance
        //     .collection('forestdata')
        //     .orderBy('createdAt', descending: true)
        //     .get();
      }
      else{
        await FirebaseFirestore.instance
            .collection('forestdata')
            .where('user_email', isEqualTo: userEmail)
            .orderBy('createdAt', descending: true)
            .get();

        jsonResult = [];
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
            userEmail: "guard email",
            person_name: doc['name'],
            person_gender: doc['gender'],
            pincodeName: doc['pincode'],
            sp_causing_death: doc['sp_causing_death'],
            village_name: doc['village_name'],
            datetime: TimeStamp.fromDate( DateTime.parse(doc['created_at']) ),
            location: G.GeoPoint(
                latitude: double.parse( doc['latitude'] ),
                longitude: double.parse( doc['longitude'] )
            ),
            userContact: "contact",
            userImage: "user photo"
        );
        _conflictList.add(conflict);
      }).toList();

      await hiveService.setBox(_conflictList, "conflictTable");
    }

    return _conflictList;
  }

  static Future<void> addConflict( Conflict conflictData, { image } ) async {
    // getting the document reference
    final docRef = FirebaseFirestore.instance.collection('forestdata').doc();

    // Upload the image to Cloud Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('forest_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');


    // loading the image
    var uploadTask;

    if( image != null ) {
      uploadTask = storageRef.putFile(image);
    }
    else {
      File _image =  File( conflictData.imageUrl );
      uploadTask = storageRef.putFile(_image);
    }

    final snapshot = await uploadTask.whenComplete(() => null);
    final String imageUrl = await snapshot.ref.getDownloadURL();

    conflictData.imageUrl = imageUrl;
    conflictData.id = docRef.id;

    await docRef.set(conflictData.toMap);
  }
}
