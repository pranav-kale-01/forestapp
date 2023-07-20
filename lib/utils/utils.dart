import 'package:connectivity_plus/connectivity_plus.dart';

class Util {
  static bool hasUserLocation = false;
}
Future<bool> get hasConnection async => ( await Connectivity().checkConnectivity() ) != ConnectivityResult.none;

