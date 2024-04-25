import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";

/// This class represents the data of a challenge

@immutable
class ChallengeData {
  final bool isCompleted;
  static const String isCompletedField = "isCompleted";

  final Timestamp expiresOn;
  static const String expiresOnField = "expiresOn";

  const ChallengeData({
    required this.isCompleted,
    required this.expiresOn,
  });

  /// Creates a ChallengeData object from a map, that is usually from a Firestore document
  factory ChallengeData.fromDb(Map<String, dynamic> data) {
    try {
      return ChallengeData(
        isCompleted: data[isCompletedField],
        expiresOn: data[expiresOnField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException(
          "Cannot parse challenge document: ${e.toString()}",
        );
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> toDbData() {
    return {
      isCompletedField: isCompleted,
      expiresOnField: expiresOn,
    };
  }

  /// Returns true if the challenge has expired
  bool get isExpired => expiresOn.compareTo(Timestamp.now()) < 0;

  @override
  bool operator ==(Object other) {
    return other is ChallengeData &&
        other.isCompleted == isCompleted &&
        other.expiresOn == expiresOn;
  }

  @override
  int get hashCode => Object.hash(isCompleted, expiresOn);
}
