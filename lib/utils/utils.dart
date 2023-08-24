import 'package:connectivity_plus/connectivity_plus.dart';

class Util {
  static bool hasUserLocation = false;

  // for debugging
  static bool showDebugDialog = false;
}

Future<bool> get hasConnection async => ( await Connectivity().checkConnectivity() ) != ConnectivityResult.none;
String get baseUrl => "https://aishwaryasoftware.xyz/conflict/";

