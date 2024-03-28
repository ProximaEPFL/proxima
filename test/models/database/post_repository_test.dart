import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geoflutterfire2/geoflutterfire2.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post_repository.dart";
import "package:proxima/models/database/user_repository.dart";
import "package:proxima/services/geolocation_service.dart";

import "mock_post_data.dart";

class MockGeoLocationService extends Mock implements GeoLocationService {
  @override
  Future<GeoPoint> getCurrentPosition() {
    return super.noSuchMethod(
      Invocation.method(#getCurrentPosition, []),
      returnValue: Future.value(const GeoPoint(0, 0)),
    );
  }
}

void main() {
  group("Post Location Firestore testing", () {
    test("hash overrides correctly", () {
      const geoPoint = GeoPoint(40, 20);
      const geoHash = "azdz";

      final expectedHash = Object.hash(geoPoint, geoHash);

      const location = PostLocationFirestore(
        geoPoint: geoPoint,
        geohash: "azdz",
      );

      final actualHash = location.hashCode;

      expect(actualHash, expectedHash);
    });

    test("fromDbData throw error when missing fields", () {
      final data = <String, dynamic>{
        PostLocationFirestore.geoPointField: const GeoPoint(40, 20),
      };

      expect(
        () => PostLocationFirestore.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group("Post Firestore Data testing", () {
    test("hash overrides correctly", () {
      final data = PostFirestoreData(
        ownerId: const UserFirestoreId(value: "owner_id"),
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
        PostFirestoreData.ownerIdField: "owner_id",
        PostFirestoreData.titleField: "post_tiltle",
        PostFirestoreData.descriptionField: "description",
        PostFirestoreData.publicationTimeField:
            Timestamp.fromMillisecondsSinceEpoch(4564654),
      };

      expect(
        () => PostFirestoreData.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group("Post Firestore testing", () {
    test("hash overrides correctly", () {
      const geoPoint = GeoPoint(40, 20);
      const geoHash = "azdz";

      const location = PostLocationFirestore(
        geoPoint: geoPoint,
        geohash: geoHash,
      );

      final data = PostFirestoreData(
        ownerId: const UserFirestoreId(value: "owner_id"),
        title: "post_tiltle",
        description: "description",
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(4564654),
        voteScore: 12,
      );

      final post = PostFirestore(
        id: const PostFirestoreId(value: "post_id"),
        location: location,
        data: data,
      );

      final expectedHash = Object.hash(post.id, post.location, post.data);

      final actualHash = post.hashCode;

      expect(actualHash, expectedHash);
    });
  });

  group("Post Repository testing", () {
    late FakeFirebaseFirestore firestore;
    late GeoFlutterFire geoFire;
    late GeoLocationService geoLocationService;
    late PostRepository postRepository;
    late MockFirestorePost mockFirestorePost;

    /// Helper function to set a post in the firestore db
    Future<void> setPostFirestore(PostFirestore post) async {
      final Map<String, dynamic> locationData = {
        PostLocationFirestore.geoPointField: post.location.geoPoint,
        PostLocationFirestore.geohashField: post.location.geohash,
      };

      await firestore
          .collection(PostRepository.collectionName)
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
      geoFire = GeoFlutterFire();
      geoLocationService = MockGeoLocationService();
      postRepository = PostRepository(
        firestore: firestore,
        geoFire: geoFire,
        geoLocationService: geoLocationService,
      );
      mockFirestorePost = MockFirestorePost();
    });

    final post = PostFirestore(
      id: const PostFirestoreId(value: "post_id"),
      location: const PostLocationFirestore(
        geoPoint: GeoPoint(40, 20),
        geohash: "afed",
      ),
      data: PostFirestoreData(
        ownerId: const UserFirestoreId(value: "owner_id"),
        title: "post_tiltle",
        description: "description",
        publicationTime: Timestamp.fromMillisecondsSinceEpoch(4564654),
        voteScore: 12,
      ),
    );

    test("delete post correctly", () async {
      await setPostFirestore(post);

      await postRepository.deletePost(post.id);
      final actualPost = await firestore
          .collection(PostRepository.collectionName)
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

      final postData = mockFirestorePost.generatePostData(1).first;
      final expectedPost = mockFirestorePost.createPostAt(postData, postPoint);

      await setPostFirestore(expectedPost);

      when(geoLocationService.getCurrentPosition())
          .thenAnswer((_) => Future.value(userPosition));

      final actualPosts = await postRepository.getNearPosts();
      expect(actualPosts, [expectedPost]);
    });

    test("post is not queried when far away", () async {
      const userPosition = GeoPoint(40, 20);
      const postPoint = GeoPoint(40.001, 20.001); // about 140m away

      final postData = mockFirestorePost.generatePostData(1).first;
      final expectedPost = mockFirestorePost.createPostAt(postData, postPoint);

      await setPostFirestore(expectedPost);

      when(geoLocationService.getCurrentPosition())
          .thenAnswer((_) => Future.value(userPosition));

      final actualPosts = await postRepository.getNearPosts();
      expect(actualPosts, isEmpty);
    });

    test("post on edge (inside) is queried", () async {
      const userPosition = GeoPoint(41, 52);
      const postPoint = GeoPoint(
        40.999999993872564,
        52.001188563379976 - 1e-5,
      ); // just below 100m away

      final postData = mockFirestorePost.generatePostData(1).first;
      final expectedPost = mockFirestorePost.createPostAt(postData, postPoint);

      await setPostFirestore(expectedPost);

      when(geoLocationService.getCurrentPosition())
          .thenAnswer((_) => Future.value(userPosition));

      final actualPosts = await postRepository.getNearPosts();
      expect(actualPosts, [expectedPost]);
    });

    test("post on edge (outside) is not queried", () async {
      const userPosition = GeoPoint(41, 52);
      const postPoint = GeoPoint(
        40.999999993872564,
        52.001188563379976 + 1e-5,
      ); // just above 100m away

      final postData = mockFirestorePost.generatePostData(1).first;
      final expectedPost = mockFirestorePost.createPostAt(postData, postPoint);

      await setPostFirestore(expectedPost);

      when(geoLocationService.getCurrentPosition())
          .thenAnswer((_) => Future.value(userPosition));

      final actualPosts = await postRepository.getNearPosts();
      expect(actualPosts, isEmpty);
    });

    test("add post at current location correctly", () async {
      const userPosition = GeoPoint(40, 20);
      final userGeoFirePoint =
          GeoFirePoint(userPosition.latitude, userPosition.longitude);

      final postData = mockFirestorePost.generatePostData(1).first;

      when(geoLocationService.getCurrentPosition())
          .thenAnswer((_) => Future.value(userPosition));

      await postRepository.addPost(postData);

      final actualPosts =
          await firestore.collection(PostRepository.collectionName).get();
      expect(actualPosts.docs.length, 1);

      final expectedPost = PostFirestore(
        id: PostFirestoreId(value: actualPosts.docs.first.id),
        location: PostLocationFirestore(
          geoPoint: userPosition,
          geohash: userGeoFirePoint.hash,
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

      final postsData = mockFirestorePost.generatePostData(nbPosts);

      final allPosts = List.generate(nbPosts, (i) {
        return mockFirestorePost.createPostAt(
          postsData[i],
          pointList[i],
          id: "post_$i",
        );
      });

      await setPostsFirestore(allPosts);

      when(geoLocationService.getCurrentPosition())
          .thenAnswer((_) => Future.value(userPosition));

      final actualPosts = await postRepository.getNearPosts();

      final expectedPosts = allPosts.where((element) {
        final geoFirePoint = GeoFirePoint(
          element.location.geoPoint.latitude,
          element.location.geoPoint.longitude,
        );
        final distance = geoFirePoint.distance(
          lat: userPosition.latitude,
          lng: userPosition.longitude,
        );
        return distance <= PostRepository.kmPostRadius;
      }).toList();

      expect(actualPosts, expectedPosts);
    });
  });
}
