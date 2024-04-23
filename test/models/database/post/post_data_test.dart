import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_data.dart";

import "../../../mocks/data/mock_position.dart";
import "../../../mocks/data/mock_post_data.dart";
import "../../../mocks/data/mock_post_firestore.dart";

void main() {
  group("Post Data testing", () {
    test("hash overrides correctly", () {
      final data = PostDataGenerator.generatePostData(1).first;

      final expectedHash = Object.hash(
        data.ownerId,
        data.title,
        data.description,
        data.publicationTime,
        data.voteScore,
      );

      final actualHash = data.hashCode;
      expect(actualHash, expectedHash);

      const geoPoint = userPosition1;
      final post = PostFirestoreGenerator.createPostAt(data, geoPoint);
      final expectedHash2 = Object.hash(post.id, post.location, post.data);
      final actualHash2 = post.hashCode;
      expect(actualHash2, expectedHash2);
    });

    test("fromDbData throw error when missing fields", () {
      final data = <String, dynamic>{
        PostData.ownerIdField: "owner_id",
        PostData.titleField: "post_tiltle",
        PostData.descriptionField: "description",
        PostData.publicationTimeField:
            Timestamp.fromMillisecondsSinceEpoch(4564654),
      };

      expect(
        () => PostData.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
