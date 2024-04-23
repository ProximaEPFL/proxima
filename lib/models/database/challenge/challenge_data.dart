import "package:flutter/foundation.dart";

@immutable
class ChallengeData {
  static const subCollectionName = "challenges";

  final bool isCompleted;
  static const String isCompletedField = "isCompleted";

  const ChallengeData({
    required this.isCompleted,
  });

  factory ChallengeData.fromDb(Map<String, dynamic> data) {
    try {
      return ChallengeData(
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

  @override
  bool operator ==(Object other) {
    return other is ChallengeData && other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => isCompleted.hashCode;
}
