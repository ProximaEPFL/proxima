import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

import "firestore_user.dart";

class PostDataGenerator {
  final emptyPost = PostData(
    ownerId: const UserIdFirestore(value: "owner_id"),
    title: "",
    description: "",
    publicationTime: Timestamp.fromMillisecondsSinceEpoch(0),
    voteScore: 0,
  );

  final postData = PostData(
    ownerId: testingUserFirestoreId,
    title: "I like turtles",
    description: "Look at them go!",
    publicationTime: Timestamp.now(),
    voteScore: 0,
  );

  /// Generate a list of [PostData]
  static List<PostData> generatePostData(int count) {
    return List.generate(count, (i) {
      return PostData(
        description: "description_$i",
        title: "title_$i",
        ownerId: UserIdFirestore(value: "owner_id_$i"),
        // one every 5 days
        publicationTime:
            Timestamp.fromMillisecondsSinceEpoch(i * 1000 * 60 * 60 * 24 * 5),
        // to have some increasing/decreasing parts
        voteScore: i * (i - 5) * (i - 10) * (i - 15),
      );
    });
  }
}
