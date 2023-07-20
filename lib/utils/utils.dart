import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> get hasConnection async => ( await Connectivity().checkConnectivity() ) != ConnectivityResult.none;

