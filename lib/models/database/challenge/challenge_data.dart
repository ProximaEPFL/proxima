import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";

@immutable
class ChallengeData {
  static const subCollectionName = "challenges";

  final bool isCompleted;
  static const String isCompletedField = "isCompleted";

  final Timestamp expiresOn;
  static const String expiresOnField = "expiresOn";

  const ChallengeData({
    required this.isCompleted,
    required this.expiresOn,
  });

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

  @override
  bool operator ==(Object other) {
    return other is ChallengeData &&
        other.isCompleted == isCompleted &&
        other.expiresOn == expiresOn;
  }

  @override
  int get hashCode => Object.hash(isCompleted, expiresOn);
}
