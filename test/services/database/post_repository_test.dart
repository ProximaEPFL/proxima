import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/vote/upvote_state.dart";
import "package:proxima/models/database/vote/vote_firestore.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/upvote_repository_service.dart";

import "../../mocks/data/firestore_comment.dart";
import "../../mocks/data/firestore_post.dart";
import "../../mocks/data/firestore_user.dart";
import "../../mocks/data/geopoint.dart";
import "../../mocks/data/post_data.dart";

void main() {
  group("Post Repository testing", () {
    late FakeFirebaseFirestore firestore;
    late PostRepositoryService postRepository;

    const kmRadius = 0.1;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      postRepository = PostRepositoryService(
        firestore: firestore,
      );
    });

    final post = FirestorePostGenerator().generatePostAt(
      userPosition2,
    );

    test("Delete post correctly", () async {
      await setPostFirestore(post, firestore);

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

    test("Delete method deletes subcollections", () async {
      await setPostFirestore(post, firestore);
      final postRef =
          firestore.collection(PostFirestore.collectionName).doc(post.id.value);
      // Check that the post is in the db
      final dbPost = await postRef.get();
      expect(dbPost.exists, true);

      final commentRepository = CommentRepositoryService(firestore: firestore);
      await CommentFirestoreGenerator()
          .addComments(4, post.id, commentRepository);

      final upvoteRepository = UpvoteRepositoryService<PostIdFirestore>(
        firestore: firestore,
        parentCollection: firestore.collection(PostFirestore.collectionName),
        voteScoreField: VoteFirestore.votersSubCollectionName,
      );

      await upvoteRepository.setUpvoteState(
        testingUserFirestoreId,
        post.id,
        UpvoteState.upvoted,
      );

      await postRepository.deletePost(post.id);
      final actualPost = await postRef.get();
      expect(actualPost.exists, false);

      final actualComments =
          await postRef.collection(CommentFirestore.subCollectionName).get();
      expect(actualComments.docs.length, 0);

      final actualVoters =
          await postRef.collection(VoteFirestore.votersSubCollectionName).get();
      expect(actualVoters.size, 0);
    });

    test("Get post correctly", () async {
      await setPostFirestore(post, firestore);

      final actualPost = await postRepository.getPost(post.id);
      expect(actualPost, post);
    });

    test("Get single nearby post correctly", () async {
      const userPosition = userPosition1;
      final expectedPost = FirestorePostGenerator().generatePostAt(
        GeoPointGenerator.createNearbyPosition(userPosition),
      );

      await setPostFirestore(expectedPost, firestore);

      final actualPosts =
          await postRepository.getNearPosts(userPosition, kmRadius);
      expect(actualPosts, [expectedPost]);
    });

    test("Post is not queried when far away", () async {
      const userPosition = userPosition1;

      final expectedPost = FirestorePostGenerator().generatePostAt(
        GeoPointGenerator.createFarAwayPosition(userPosition, kmRadius),
      );

      await setPostFirestore(expectedPost, firestore);

      final actualPosts =
          await postRepository.getNearPosts(userPosition1, kmRadius);
      expect(actualPosts, isEmpty);
    });

    test("Post on edge (inside) is queried", () async {
      const userPosition = userPosition1;
      final expectedPost = FirestorePostGenerator().generatePostAt(
        GeoPointGenerator.createOnEdgeInsidePosition(userPosition, kmRadius),
      );

      await setPostFirestore(expectedPost, firestore);

      final actualPosts =
          await postRepository.getNearPosts(userPosition1, kmRadius);
      expect(actualPosts, [expectedPost]);
    });

    test("Post on edge (outside) is not queried", () async {
      const userPosition = userPosition1;
      final expectedPost = FirestorePostGenerator().generatePostAt(
        GeoPointGenerator.createOnEdgeOutsidePosition(userPosition, kmRadius),
      );

      await setPostFirestore(expectedPost, firestore);

      final actualPosts =
          await postRepository.getNearPosts(userPosition1, kmRadius);
      expect(actualPosts, isEmpty);
    });

    test("Near posts with min radius works", () async {
      const userPosition = userPosition1;
      const double minRadius = 1;
      const double maxRadius = 5;

      final generator = FirestorePostGenerator();
      final tooClose = generator.generatePostAt(
        GeoPointGenerator.createOnEdgeInsidePosition(userPosition, minRadius),
      );
      final good = generator.generatePostAt(
        GeoPointGenerator.createOnEdgeInsidePosition(userPosition, maxRadius),
      );
      final tooFar = generator.generatePostAt(
        GeoPointGenerator.createOnEdgeOutsidePosition(userPosition, maxRadius),
      );

      await setPostsFirestore([tooClose, good, tooFar], firestore);
      final actualPosts =
          await postRepository.getNearPosts(userPosition, maxRadius, minRadius);

      expect(actualPosts, [good]);
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
      final pointList = GeoPointGenerator.generatePositions(
        userPosition0,
        nbPostsInRange,
        nbPosts - nbPostsInRange,
      );

      final postsData = PostDataGenerator.generatePostData(nbPosts);

      final allPosts = List.generate(nbPosts, (i) {
        return FirestorePostGenerator().createPostAt(
          postsData[i],
          pointList[i],
          id: "post_$i",
        );
      });

      await setPostsFirestore(allPosts, firestore);

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
      final generator = FirestorePostGenerator();
      const userId1 = UserIdFirestore(value: "user_id_1");

      final postsData1 = generator.createUserPost(userId1, userPosition2);
      final postsData2 = generator.createUserPost(userId1, userPosition3);
      await setPostsFirestore([postsData1, postsData2], firestore);

      const userId2 = UserIdFirestore(value: "user_id_2");

      final postsData3 = generator.createUserPost(userId2, userPosition2);
      final postsData4 = generator.createUserPost(userId2, userPosition3);
      await setPostsFirestore([postsData3, postsData4], firestore);

      final actualPosts1 = await postRepository.getUserPosts(userId1);
      final actualPosts2 = await postRepository.getUserPosts(userId2);

      expect(actualPosts1, unorderedEquals([postsData1, postsData2]));
      expect(actualPosts2, unorderedEquals([postsData3, postsData4]));
    });

    test("post exists works", () async {
      final existsBeforeCreation = await postRepository.postExists(post.id);
      expect(existsBeforeCreation, false);

      await setPostFirestore(post, firestore);

      final exists = await postRepository.postExists(post.id);
      expect(exists, true);

      await postRepository.deletePost(post.id);

      final existAfterDeletion = await postRepository.postExists(post.id);
      expect(existAfterDeletion, false);
    });
  });
}
