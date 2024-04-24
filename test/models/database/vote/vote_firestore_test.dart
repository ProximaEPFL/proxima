import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/vote/vote_firestore.dart";

void main() {
  group("Vote Firestore testing", () {
    test("hash overrides correctly", () {
      final voteFirestore = VoteFirestore(hasUpvoted: true);
      final hashCode = voteFirestore.hashCode;

      expect(hashCode, true.hashCode);
    });

    test("equality overrides correctly", () {
      final voteFirestore = VoteFirestore(hasUpvoted: true);
      final voteFirestoreCopy = VoteFirestore(hasUpvoted: true);

      expect(voteFirestore, voteFirestoreCopy);
    });
  });
}
