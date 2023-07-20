import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/common/models/timestamp.dart';
import 'package:forestapp/common/models/geopoint.dart' as G;
import 'package:forestapp/utils/hive_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forestapp/utils/utils.dart';

class ConflictService {
  static HiveService hiveService = HiveService();

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

      var result;

      if( userEmail.isEmpty ) {
        result = await FirebaseFirestore.instance
            .collection('forestdata')
            .orderBy('createdAt', descending: true)
            .get();
      }
      else{
        result = await FirebaseFirestore.instance
            .collection('forestdata')
            .where('user_email', isEqualTo: userEmail)
            .orderBy('createdAt', descending: true)
            .get();
      }

      (result.docs).map((doc) {
        Conflict conflict = Conflict(
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
            datetime: TimeStamp(
                seconds: doc['createdAt'].seconds,
                nanoseconds: doc['createdAt'].nanoseconds),
            location: G.GeoPoint(
                latitude: doc['location'].latitude,
                longitude: doc['location'].longitude),
            userContact: doc['user_contact'],
            userImage: doc['user_imageUrl']);

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
