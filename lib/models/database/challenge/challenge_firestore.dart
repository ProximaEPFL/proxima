import "package:flutter/foundation.dart";

@immutable
class ChallengeFirestore {
  static const subCollectionName = "challenges";

  final bool isCompleted;
  static const String isCompletedField = "isCompleted";

  const ChallengeFirestore({
    required this.isCompleted,
  });

  factory ChallengeFirestore.fromDb(Map<String, dynamic> data) {
    try {
      return ChallengeFirestore(
        isCompleted: data[isCompletedField],
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException(
            "Cannot parse challenge document: ${e.toString()}");
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> toDbData() {
    return {
      isCompletedField: isCompleted,
    };
  }
}
