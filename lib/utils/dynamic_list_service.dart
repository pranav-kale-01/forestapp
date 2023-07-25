import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:forestapp/utils/utils.dart' show baseUrl;

class DynamicListService {
  static Future<Map<String, dynamic>> fetchDynamicLists( BuildContext context ) async {
    // fetching all the dynamic lists
    Map<String, dynamic> dynamicLists = {};

    // range
    var request = http.Request('GET', Uri.parse('${baseUrl}admin/get_ranges'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // mapping the dynamic Lists
      List<dynamic> jsonResponse =
          jsonDecode(await response.stream.bytesToString());
      dynamicLists['range'] = jsonResponse.where( (item) => item['id'] != "-1"  ).map((item) => {"id": item['id'], "name": item['range_name']})
          .toList();
    } else {
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

    // round
    request = http.Request('GET', Uri.parse('${baseUrl}admin/get_rounds'));
    response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse =
          jsonDecode(await response.stream.bytesToString());
      dynamicLists['round'] = jsonResponse.
            where( (item) => item['id'] != "-1"  ).map((item) => {
                'id': item['id'],
                'name': item['round_name'],
                'range_id': item['range_id']
              })
          .toList();
    } else {
      print(response.reasonPhrase);
    }

    // beat
    request = http.Request('GET', Uri.parse('${baseUrl}admin/get_beats'));
    response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(await response.stream.bytesToString());
      dynamicLists['beat'] =
          jsonResponse.where( (item) => item['id'] != "-1"  ).map((item) => {
            'id' : item['id'],
            'name' : item['beat_name'],
            'round_id' : item['round_id']
          }).toList();
    } else {
      print(response.reasonPhrase);
    }

    // conflict
    request =
        http.Request('GET', Uri.parse('${baseUrl}admin/get_conflict_types'));
    response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(await response.stream.bytesToString());
      dynamicLists['conflict'] = jsonResponse.where( (item) => item['id'] != "-1"  ).map((item) => { "id" : item['id'], "name" : item['conflict_name'] }).toList();
    } else {
      print(response.reasonPhrase);
    }

    return dynamicLists;
  }

  static Future<int> addField( BuildContext context, String type, String value, {range_id = "", round_id = "" } ) async {
    String endpoint = "";
    Map<String, String> fields = {};

    // setting the values as per the type
    if( type == 'range' ) {
      endpoint = "add_range";
      fields.addAll( {"range_name" : value} );
    }
    else if( type == 'round' ) {
      endpoint = "add_round";
      fields.addAll( {'round_name' : value, 'range_id' : range_id } );
    }
    else if( type == 'beat' ) {
      endpoint = "add_beat";
      fields.addAll( { 'beat_name' : value, 'range_id' : range_id, 'round_id' : round_id } );
    }
    else {
      endpoint = "add_conflict_type";
      fields.addAll( {'conflict_name' : value } );
    }

    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/$endpoint'));
    request.fields.addAll(fields);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode( await response.stream.bytesToString() );
      return int.parse( jsonResponse['message'] );
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

      return -1;
    }
  }

  static Future<void> removeField( BuildContext context, String type, Map<String, dynamic> item ) async {
    String endpoint = "";
    Map<String, String> fields = {};

    // setting the values as per the type
    if( type == 'range' ) {
      endpoint = "delete_range";
      fields.addAll( {"id" : item['id']} );
    }
    else if( type == 'round' ) {
      endpoint = "delete_round";
      fields.addAll( {'round_id' : item['id'] } );
    }
    else if( type == 'beat' ) {
      endpoint = "delete_beat";
      fields.addAll( { 'beat_id' : item['id'] } );
    }
    else {
      endpoint = "delete_conflict_type";
      fields.addAll( {'id' : item['id'] } );
    }

    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}admin/$endpoint'));
    request.fields.addAll(fields);

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
  }

}
