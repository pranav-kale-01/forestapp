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

  /// Converts [TimeStamp] to [DateTime]
  DateTime toDate() {
    return DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
  }

  /// Create a [TimeStamp] fromMillisecondsSinceEpoch
  factory TimeStamp.fromMillisecondsSinceEpoch(int milliseconds) {
    int seconds = (milliseconds / _kThousand).floor();
    final int nanoseconds = (milliseconds - seconds * _kThousand) * _kMillion;
    return TimeStamp( seconds: seconds, nanoseconds: nanoseconds);
  }

  /// Create a [TimeStamp] fromMicrosecondsSinceEpoch
  factory TimeStamp.fromMicrosecondsSinceEpoch(int microseconds) {
    final int seconds = microseconds ~/ _kMillion;
    final int nanoseconds = (microseconds - seconds * _kMillion) * _kThousand;
    return TimeStamp( seconds: seconds, nanoseconds: nanoseconds);
  }

  /// Create a [TimeStamp] from [DateTime] instance
  factory TimeStamp.fromDate(DateTime date) {
    return TimeStamp.fromMicrosecondsSinceEpoch(date.microsecondsSinceEpoch);
  }

  /// Create a [TimeStamp] from [DateTime].now()
  factory TimeStamp.now() {
    return TimeStamp.fromMicrosecondsSinceEpoch(
      DateTime.now().microsecondsSinceEpoch,
    );
  }

}

