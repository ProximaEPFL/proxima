import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

void main() {
  group("Post Data testing", () {
    test("hash overrides correctly", () {
      final data = PostData(
        ownerId: const UserIdFirestore(value: "owner_id"),
        title: "post_tiltle",
        description: "description",
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(4564654),
        voteScore: 12,
      );

      final expectedHash = Object.hash(
        data.ownerId,
        data.title,
        data.description,
        data.publicationTime,
        data.voteScore,
      );

      final actualHash = data.hashCode;

      expect(actualHash, expectedHash);
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
