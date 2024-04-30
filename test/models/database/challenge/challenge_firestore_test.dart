import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";
import "package:proxima/models/database/challenge/challenge_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";

void main() {
  test("hash and == works", () {
    final now = Timestamp.now();
    final data = ChallengeData(isCompleted: false, expiresOn: now);
    final sameData = ChallengeData(isCompleted: false, expiresOn: now);

    const postId1 = PostIdFirestore(value: "1");
    const postId2 = PostIdFirestore(value: "2");

    final a = ChallengeFirestore(postId: postId1, data: data);
    final b = ChallengeFirestore(postId: postId2, data: data);
    final c = ChallengeFirestore(postId: postId1, data: sameData);

    expect(a, isNot(b));
    expect(a.hashCode, isNot(b.hashCode));

    expect(a, c);
    expect(a.hashCode, c.hashCode);
  });
}
