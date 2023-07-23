import 'dart:convert';
import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/common/models/geopoint.dart';
import 'package:forestapp/utils/hive_service.dart';
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

  static Future<List<Conflict>> getRecentEntries( { String userEmail = "" } ) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/get_recent_entries'));
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
            userContact: "contact",
            userImage: "user photo"
        )
      ).toList();
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
        return [];
      }

      jsonResult.map((doc) {
        print( doc['id'] );
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
            userContact: "contact",
            userImage: "user photo"
        );
        _conflictList.add(conflict);
      }).toList();

      await hiveService.setBox(_conflictList, "conflictTable");
    }

    return _conflictList;
  }

  static Future<void> addConflict( Conflict conflict ) async {
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
      'longitude':  conflict.location.longitude.toString()
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

    // getting the document reference
    // final docRef = FirebaseFirestore.instance.collection('forestdata').doc();

    // Upload the image to Cloud Storage
    // final storageRef = FirebaseStorage.instance
    //     .ref()
    //     .child('forest_images')
    //     .child('${DateTime.now().millisecondsSinceEpoch}.jpg');


    // // loading the image
    // var uploadTask;
    //
    // if( image != null ) {
    //   uploadTask = storageRef.putFile(image);
    // }
    // else {
    //   File _image =  File( conflictData.imageUrl );
    //   uploadTask = storageRef.putFile(_image);
    // }
    //
    // final snapshot = await uploadTask.whenComplete(() => null);
    // final String imageUrl = await snapshot.ref.getDownloadURL();
    //
    // conflictData.imageUrl = imageUrl;
    // conflictData.id = docRef.id;
    //
    // await docRef.set(conflictData.toMap);
  }

  static Future<Conflict> editConflict( Map<String, dynamic> data ) async {
    // sending a api request to update Conflict
    var request = http.MultipartRequest('POST', Uri.parse('https://aishwaryasoftware.xyz/conflict/guard//edit_conflict'));
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
      'latitude': data['latitude'].toString(),
      'longitude': data['longitude'].toString(),
    });


    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
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

  static Future<bool> deleteConflict( String conflictId ) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}guard/delete_conflict'));

    request.fields.addAll({
      'id': conflictId
    });

    http.StreamedResponse response = await request.send();
    print( await response.stream.bytesToString( ) );

    if( response.statusCode != 200 ) {
      print( await response.stream.bytesToString() );
      print( response.reasonPhrase.toString() );

    }

    return response.statusCode == 200;
  }

}
