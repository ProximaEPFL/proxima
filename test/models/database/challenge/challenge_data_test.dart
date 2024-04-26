import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/challenge/challenge_data.dart";

void main() {
  test("Hash and == works", () {
    final now = Timestamp.now();
    ChallengeData a = ChallengeData(isCompleted: false, expiresOn: now);
    ChallengeData b = ChallengeData(isCompleted: false, expiresOn: now);

    expect(a.hashCode, b.hashCode);
    expect(a, b);

    ChallengeData c = ChallengeData(isCompleted: true, expiresOn: now);
    expect(a.hashCode, isNot(c.hashCode));
    expect(a, isNot(c));
  });
}
