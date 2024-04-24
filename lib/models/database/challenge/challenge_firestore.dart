import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

/// This class represents a challenge in the Firestore database

@immutable
class ChallengeFirestore {
  static const subCollectionName = "challenges";
  static const pastChallengesSubCollectionName = "pastChallenges";

  final PostIdFirestore postId;
  final ChallengeData data;

  const ChallengeFirestore({
    required this.postId,
    required this.data,
  });

  factory ChallengeFirestore.fromDb(DocumentSnapshot docSnap) {
    try {
      final data = docSnap.data() as Map<String, dynamic>;

      return ChallengeFirestore(
        postId: PostIdFirestore(value: docSnap.id),
        data: ChallengeData.fromDb(data),
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

  @override
  bool operator ==(Object other) {
    return other is ChallengeFirestore &&
        other.postId == postId &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(postId, data);
}
