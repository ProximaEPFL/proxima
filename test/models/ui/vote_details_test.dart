import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/vote/vote_state.dart";
import "package:proxima/models/ui/votes_details.dart";

void main() {
  group("Post Vote testing", () {
    test("hash overrides correclty", () {
      const postVote = VotesDetails(
        upvoteState: VoteState.upvoted,
        votes: 12,
      );

      final expectedHash = Object.hash(
        postVote.upvoteState,
        postVote.votes,
      );

      final actualHash = postVote.hashCode;

      expect(actualHash, expectedHash);
    });

    test("equality overrides correctly", () {
      const postVote = VotesDetails(
        upvoteState: VoteState.upvoted,
        votes: 12,
      );

      const postVoteCopy = VotesDetails(
        upvoteState: VoteState.upvoted,
        votes: 12,
      );

      expect(postVote, postVoteCopy);
    });
  });
}
