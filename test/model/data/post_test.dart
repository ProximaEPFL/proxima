import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/data/location.dart";
import "package:proxima/models/data/post.dart";
import "package:proxima/models/data/user.dart";

void main() {
  group("Post representation testing", () {
    test("Post correctly created", () {
      final post = Post(
        id: "post_id",
        title: "post_title",
        description: "post_description",
        location: Location(longitude: -155.5, latitude: 85.8),
        publicationTime: DateTime.utc(2021, 1, 1),
        voteScore: 0,
        comments: [],
        owner: CurrentUser(
          id: "user_id",
          displayName: "user_displayName",
          username: "user_username",
          joinTime: DateTime.utc(2021, 1, 1),
        ),
      );

      expect(post.id, "post_id");
      expect(post.title, "post_title");
      expect(post.description, "post_description");
      expect(post.location.longitude, -155.5);
      expect(post.location.latitude, 85.8);
      expect(post.publicationTime, DateTime.utc(2021, 1, 1));
      expect(post.voteScore, 0);
      expect(post.comments, []);
      expect(post.owner.id, "user_id");
      expect(post.owner.displayName, "user_displayName");
      expect(post.owner.username, "user_username");
    });
  });
}
