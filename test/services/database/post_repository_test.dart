import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/post_repository_service.dart";

import "../../mocks/data/mock_firestore_post.dart";
import "../../mocks/data/mock_position.dart";
import "../../mocks/data/mock_post_data.dart";

void main() {
  group("Post Repository testing", () {
    late FakeFirebaseFirestore firestore;
    late PostRepositoryService postRepository;

    const kmRadius = 0.1;

    /// Helper function to set a post in the firestore db
    Future<void> setPostFirestore(PostFirestore post) async {
      final Map<String, dynamic> locationData = {
        PostLocationFirestore.geoPointField: post.location.geoPoint,
        PostLocationFirestore.geohashField: post.location.geohash,
      };

      await firestore
          .collection(PostFirestore.collectionName)
          .doc(post.id.value)
          .set({
        PostFirestore.locationField: locationData,
        ...post.data.toDbData(),
      });
    }

    Future<void> setPostsFirestore(List<PostFirestore> posts) async {
      for (final post in posts) {
        await setPostFirestore(post);
      }
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();
      postRepository = PostRepositoryService(
        firestore: firestore,
      );
    });

    final post = FirestorePostGenerator.generatePostAt(
      userPosition2,
    );

    test("Delete post correctly", () async {
      await setPostFirestore(post);

      // Check that the post is in the db
      final dbPost = await firestore
          .collection(PostFirestore.collectionName)
          .doc(post.id.value)
          .get();
      expect(dbPost.exists, true);

      await postRepository.deletePost(post.id);
      final actualPost = await firestore
          .collection(PostFirestore.collectionName)
          .doc(post.id.value)
          .get();
      expect(actualPost.exists, false);
    });

    test("Get post correctly", () async {
      await setPostFirestore(post);

      final actualPost = await postRepository.getPost(post.id);
      expect(actualPost, post);
    });

    test("Get single nearby post correctly", () async {
      const userPosition = userPosition1;
      final expectedPost = FirestorePostGenerator.generatePostAt(
        GeoPointGenerator().createNearbyPostPosition(userPosition),
      );

      await setPostFirestore(expectedPost);

      final actualPosts =
          await postRepository.getNearPosts(userPosition, kmRadius);
      expect(actualPosts, [expectedPost]);
    });

    test("Post is not queried when far away", () async {
      const userPosition = userPosition1;

      final expectedPost = FirestorePostGenerator.generatePostAt(
        GeoPointGenerator().createFarAwayPostPosition(userPosition, kmRadius),
      );

      await setPostFirestore(expectedPost);

      final actualPosts =
          await postRepository.getNearPosts(userPosition1, kmRadius);
      expect(actualPosts, isEmpty);
    });

    test("Post on edge (inside) is queried", () async {
      const userPosition = userPosition1;
      final expectedPost = FirestorePostGenerator.generatePostAt(
        GeoPointGenerator()
            .createPostOnEdgeInsidePosition(userPosition, kmRadius),
      );

      await setPostFirestore(expectedPost);

      final actualPosts =
          await postRepository.getNearPosts(userPosition1, kmRadius);
      expect(actualPosts, [expectedPost]);
    });

    test("Post on edge (outside) is not queried", () async {
      const userPosition = userPosition1;
      final expectedPost = FirestorePostGenerator.generatePostAt(
        GeoPointGenerator()
            .createPostOnEdgeOutsidePosition(userPosition, kmRadius),
      );

      await setPostFirestore(expectedPost);

      final actualPosts =
          await postRepository.getNearPosts(userPosition1, kmRadius);
      expect(actualPosts, isEmpty);
    });

    test("Add post at location correctly", () async {
      const userGeoFirePoint = GeoFirePoint(userPosition1);

      final postData = PostDataGenerator.generatePostData(1).first;

      await postRepository.addPost(postData, userPosition1);

      final actualPosts =
          await firestore.collection(PostFirestore.collectionName).get();
      expect(actualPosts.docs.length, 1);

      final expectedPost = PostFirestore(
        id: PostIdFirestore(value: actualPosts.docs.first.id),
        location: PostLocationFirestore(
          geoPoint: userPosition1,
          geohash: userGeoFirePoint.geohash,
        ),
        data: postData,
      );

      final actualPost = PostFirestore.fromDb(actualPosts.docs.first);
      expect(actualPost, expectedPost);
    });

    test("Get multiple nearby posts correctly", () async {
      const nbPosts = 10;
      const nbPostsInRange = 7;

      // The 7 first posts are under 100m away from the user and are the ones expected
      final pointList = GeoPointGenerator().generatePositions(
        userPosition0,
        nbPostsInRange,
        nbPosts - nbPostsInRange,
      );

      final postsData = PostDataGenerator.generatePostData(nbPosts);

      final allPosts = List.generate(nbPosts, (i) {
        return FirestorePostGenerator.createPostAt(
          postsData[i],
          pointList[i],
          id: "post_$i",
        );
      });

      await setPostsFirestore(allPosts);

      final actualPosts =
          await postRepository.getNearPosts(userPosition1, kmRadius);

      final expectedPosts = allPosts.where((element) {
        final geoFirePoint = GeoFirePoint(element.location.geoPoint);
        final distance = geoFirePoint.distanceBetweenInKm(
          geopoint: userPosition1,
        );
        return distance <= kmRadius;
      }).toList();

      expect(actualPosts, expectedPosts);
    });

    test("Get simple user posts correctly", () async {
      const userId1 = UserIdFirestore(value: "user_id_1");

      final postsData1 =
          FirestorePostGenerator.createUserPost(userId1, userPosition2);
      final postsData2 =
          FirestorePostGenerator.createUserPost(userId1, userPosition3);
      await setPostsFirestore([postsData1, postsData2]);

      const userId2 = UserIdFirestore(value: "user_id_2");

      final postsData3 =
          FirestorePostGenerator.createUserPost(userId2, userPosition2);
      final postsData4 =
          FirestorePostGenerator.createUserPost(userId2, userPosition3);
      await setPostsFirestore([postsData3, postsData4]);

      final actualPosts1 = await postRepository.getUserPosts(userId1);
      final actualPosts2 = await postRepository.getUserPosts(userId2);

      expect(actualPosts1, unorderedEquals([postsData1, postsData2]));
      expect(actualPosts2, unorderedEquals([postsData3, postsData4]));
    });

    test("post exists works", () async {
      await setPostFirestore(post);

      final exists = await postRepository.postExists(post.id);
      expect(exists, true);

      await postRepository.deletePost(post.id);

      final existAfterDeletion = await postRepository.postExists(post.id);
      expect(existAfterDeletion, false);
    });
  });
}
