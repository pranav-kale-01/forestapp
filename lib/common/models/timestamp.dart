import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
part 'timestamp.g.dart';

const int _kThousand = 1000;
const int _kMillion = 1000000;

@HiveType( typeId: 2 )
class TimeStamp extends firestore.Timestamp {
  @HiveField(0)
  int seconds;

  @HiveField(1)
  int nanoseconds;

  TimeStamp( {
    required this.seconds,
    required this.nanoseconds
  }) : super( seconds, nanoseconds );

  // ignore: public_member_api_docs
  int get microsecondsSinceEpoch =>
      this.seconds * _kMillion + nanoseconds ~/ _kThousand;

  /// Converts [Timestamp] to [DateTime]
  DateTime toDate() {
    return DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
  }
}

