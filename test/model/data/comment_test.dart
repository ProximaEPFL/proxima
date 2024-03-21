import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/data/comment.dart";
import "package:proxima/models/data/user.dart";

void main() {
  final commentList = List.generate(
    10,
    (i) => Comment(
      id: "comment_id_$i",
      content: "comment_content_$i",
      owner: CurrentUser(
        id: "user_id_$i",
        displayName: "user_displayName_$i",
        username: "user_username_$i",
        joinTime: DateTime.utc(2021 + i, 1, 1),
      ),
      voteScore: i,
      numberOfDirectAnswers: 0,
      loadedAnswers: [],
      publicationTime: DateTime.utc(2021 + i, 1, 1),
    ),
  );

  group("Comment representation testing", () {
    test("Comment correctly created", () {
      final comment = commentList[0];

      expect(comment.id, "comment_id_0");
      expect(comment.content, "comment_content_0");
      expect(comment.owner.id, "user_id_0");
      expect(comment.owner.displayName, "user_displayName_0");
      expect(comment.owner.username, "user_username_0");
      expect(comment.voteScore, 0);
      expect(comment.numberOfDirectAnswers, 0);
      expect(comment.loadedAnswers, []);
      expect(comment.publicationTime, DateTime.utc(2021, 1, 1));
    });
  });
}
