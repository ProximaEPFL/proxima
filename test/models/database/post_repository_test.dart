import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geoflutterfire2/geoflutterfire2.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post_repository.dart";
import "package:proxima/services/geolocation_service.dart";

class MockGeoFlutterFire extends Mock implements GeoFlutterFire {}

class MockGeoLocationService extends Mock implements GeoLocationService {}

void main() {
  group("Post Repository testing", () {
    late FakeFirebaseFirestore firestore;
    late GeoFlutterFire geoFire;
    late GeoLocationService geoLocationService;
    late PostRepository postRepository;

    /// Helper function to set a post in the firestore db
    Future<void> setPostFirestore(PostFirestore post) async {
      final Map<String, dynamic> locationData = {
        PostLocationFirestore.geoPointField: post.location.geoPoint,
        PostLocationFirestore.geohashField: post.location.geohash,
      };

      await firestore
          .collection(PostRepository.collectionName)
          .doc(post.id)
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
      geoFire = MockGeoFlutterFire();
      geoLocationService = MockGeoLocationService();
      postRepository = PostRepository(
        firestore: firestore,
        geoFire: geoFire,
        geoLocationService: geoLocationService,
      );
    });

    final post = PostFirestore(
      id: "post_id",
      location: const PostLocationFirestore(
        geoPoint: GeoPoint(40, 20),
        geohash: "afed",
      ),
      data: PostFirestoreData(
        ownerId: "owner_id",
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
          .doc(post.id)
          .get();
      expect(actualPost.exists, false);
    });
  });
}
