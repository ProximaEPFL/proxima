import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/models/ui/post_vote.dart";

void main() {
  group("Post Vote testing", () {
    test("hash overrides correclty", () {
      const postVote = PostVote(
        upvoteState: UpvoteState.upvoted,
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
      const postVote = PostVote(
        upvoteState: UpvoteState.upvoted,
        votes: 12,
      );

      const postVoteCopy = PostVote(
        upvoteState: UpvoteState.upvoted,
        votes: 12,
      );

      expect(postVote, postVoteCopy);
    });
  });
}
