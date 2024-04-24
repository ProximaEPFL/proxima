import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/post_repository_service.dart";

import "../../models/database/post/mock_post_data.dart";
import "../test_data/user_posts_fake_data.dart";

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

    final post = PostFirestore(
      id: const PostIdFirestore(value: "post_id"),
      location: const PostLocationFirestore(
        geoPoint: GeoPoint(40, 20),
        geohash: "afed",
      ),
      data: PostData(
        ownerId: const UserIdFirestore(value: "owner_id"),
        title: "post_tiltle",
        description: "description",
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(4564654),
        voteScore: 12,
      ),
    );

    test("delete post correctly", () async {
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

    test("get post correctly", () async {
      await setPostFirestore(post);

      final actualPost = await postRepository.getPost(post.id);
      expect(actualPost, post);
    });

    test("get single near post correctly", () async {
      const userPosition = GeoPoint(40, 20);
      const postPoint = GeoPoint(40.0001, 20.0001); // 14m away

      final postData = MockPostFirestore.generatePostData(1).first;
      final expectedPost = MockPostFirestore.createPostAt(postData, postPoint);

      await setPostFirestore(expectedPost);

      final actualPosts =
          await postRepository.getNearPosts(userPosition, kmRadius);
      expect(actualPosts, [expectedPost]);
    });

    test("post is not queried when far away", () async {
      const userPosition = GeoPoint(40, 20);

      const postPoint = GeoPoint(40.001, 20.001); // about 140m away

      final postData = MockPostFirestore.generatePostData(1).first;
      final expectedPost = MockPostFirestore.createPostAt(postData, postPoint);

      await setPostFirestore(expectedPost);

      final actualPosts =
          await postRepository.getNearPosts(userPosition, kmRadius);
      expect(actualPosts, isEmpty);
    });

    test("post on edge (inside) is queried", () async {
      const userPosition = GeoPoint(41, 52);
      const postPoint = GeoPoint(
        40.999999993872564,
        52.001188563379976 - 1e-5,
      ); // just below 100m away

      final postData = MockPostFirestore.generatePostData(1).first;
      final expectedPost = MockPostFirestore.createPostAt(postData, postPoint);

      await setPostFirestore(expectedPost);

      final actualPosts =
          await postRepository.getNearPosts(userPosition, kmRadius);
      expect(actualPosts, [expectedPost]);
    });

    test("post on edge (outside) is not queried", () async {
      const userPosition = GeoPoint(41, 52);
      const postPoint = GeoPoint(
        40.999999993872564,
        52.001188563379976 + 1e-5,
      ); // just above 100m away

      final postData = MockPostFirestore.generatePostData(1).first;
      final expectedPost = MockPostFirestore.createPostAt(postData, postPoint);

      await setPostFirestore(expectedPost);

      final actualPosts =
          await postRepository.getNearPosts(userPosition, kmRadius);
      expect(actualPosts, isEmpty);
    });

    test("add post at location correctly", () async {
      const userPosition = GeoPoint(40, 20);
      const userGeoFirePoint = GeoFirePoint(userPosition);

      final postData = MockPostFirestore.generatePostData(1).first;

      await postRepository.addPost(postData, userPosition);

      final actualPosts =
          await firestore.collection(PostFirestore.collectionName).get();
      expect(actualPosts.docs.length, 1);

      final expectedPost = PostFirestore(
        id: PostIdFirestore(value: actualPosts.docs.first.id),
        location: PostLocationFirestore(
          geoPoint: userPosition,
          geohash: userGeoFirePoint.geohash,
        ),
        data: postData,
      );

      final actualPost = PostFirestore.fromDb(actualPosts.docs.first);
      expect(actualPost, expectedPost);
    });

    test("get multiple near posts correctly", () async {
      const nbPosts = 10;
      const userPosition = GeoPoint(40, 20);
      // The 7 first posts are under 100m away from the user and are the ones expected
      final pointList = List.generate(nbPosts, (i) {
        return GeoPoint(40.0001 + i * 0.0001, 20.0001 + i * 0.0001);
      });

      final postsData = MockPostFirestore.generatePostData(nbPosts);

      final allPosts = List.generate(nbPosts, (i) {
        return MockPostFirestore.createPostAt(
          postsData[i],
          pointList[i],
          id: "post_$i",
        );
      });

      await setPostsFirestore(allPosts);

      final actualPosts =
          await postRepository.getNearPosts(userPosition, kmRadius);

      final expectedPosts = allPosts.where((element) {
        final geoFirePoint = GeoFirePoint(element.location.geoPoint);
        final distance = geoFirePoint.distanceBetweenInKm(
          geopoint: userPosition,
        );
        return distance <= kmRadius;
      }).toList();

      expect(actualPosts, expectedPosts);
    });

    test("get simple user posts correctly", () async {
      const userId1 = UserIdFirestore(value: "user_id_1");

      final postsData1 =
          MockPostFirestore.createUserPost(userId1, fakeDataPosition1);
      final postsData2 =
          MockPostFirestore.createUserPost(userId1, fakeDataPosition2);
      await setPostsFirestore([postsData1, postsData2]);

      const userId2 = UserIdFirestore(value: "user_id_2");

      final postsData3 =
          MockPostFirestore.createUserPost(userId2, fakeDataPosition1);
      final postsData4 =
          MockPostFirestore.createUserPost(userId2, fakeDataPosition2);
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
