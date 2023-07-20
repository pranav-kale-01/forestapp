import 'dart:io';

import 'package:forestapp/common/models/conflict_model_hive.dart';
import 'package:forestapp/common/models/timestamp.dart';
import 'package:forestapp/common/models/geopoint.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  init( )  async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init( dir.path );
    Hive.registerAdapter( GeoPointAdapter() );
    Hive.registerAdapter( TimeStampAdapter() );
    Hive.registerAdapter( ConflictAdapter() );
  }

  isExists({String? boxName}) async {
    final openBox = await Hive.openBox(boxName!);
    int length = openBox.length;
    return length != 0;
  }

  addBoxes<T>(List<T> items, String boxName) async {
    final openBox = await Hive.openBox(boxName);

    for (var item in items) {
      openBox.add(item);
    }
  }

  setBox<T>(List<T> items, String boxName) async {
    print("setBox");
    final openBox = await Hive.openBox(boxName);

    openBox.clear();
    openBox.addAll( items );
  }

  getBoxes<T>(String boxName) async {
    List<T> boxList = <T>[];

    final openBox = await Hive.openBox(boxName);

    int length = openBox.length;

    for (int i = 0; i < length; i++) {
      boxList.add(openBox.getAt(i));
    }

    return boxList;
  }
}