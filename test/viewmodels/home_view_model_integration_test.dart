import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:test/test.dart";

import "../models/database/post/mock_post_data.dart";
import "../models/database/user/mock_user_data.dart";
import "../services/mock_geo_location_service.dart";

void main() {
  // This aims to test the [postOverviewProvider] with the real implementation
  // of the [UserRepositoryService] and [PostRepositoryService] on a fake
  // firestore instance
  group("Post Overview Provider integration testing with firestore", () {
    late MockGeoLocationService geoLocationService;
    late FakeFirebaseFirestore fakeFireStore;

    late MockPostFirestore mockPostFirestore;
    late MockUserFirestore mockUserFirestore;
    late UserRepositoryService userRepo;
    late PostRepositoryService postRepo;

    late ProviderContainer container;

    // Base point used in the tests
    const userPosition = GeoPoint(0, 0);

    setUp(() async {
      fakeFireStore = FakeFirebaseFirestore();
      geoLocationService = MockGeoLocationService();

      userRepo = UserRepositoryService(
        firestore: fakeFireStore,
      );
      postRepo = PostRepositoryService(
        firestore: fakeFireStore,
      );

      container = ProviderContainer(
        overrides: [
          geoLocationServiceProvider.overrideWithValue(geoLocationService),
          userRepositoryProvider.overrideWithValue(userRepo),
          postRepositoryProvider.overrideWithValue(postRepo),
        ],
      );

      mockPostFirestore = MockPostFirestore();
      mockUserFirestore = MockUserFirestore();

      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition,
      );
    });

    test("No posts are returned when the database is empty", () async {
      final posts = await container.read(postOverviewProvider.future);

      expect(posts, isEmpty);
    });

    test("No posts are returned when they are far way from the user", () async {
      final postData = mockPostFirestore.generatePostData(1)[0];

      await postRepo.addPost(
        postData,
        const GeoPoint(1, 0), // This is >> 0.1 km away from the (0,0)
      );

      final actualPosts = await container.read(postOverviewProvider.future);

      expect(actualPosts, isEmpty);
    });

    test("Single near post returned correctly", () async {
      // Add the post owner to the database
      final owner = mockUserFirestore.generateUserFirestore(1)[0];
      await userRepo.setUser(owner.uid, owner.data);

      // Add the post to the database
      final postData = mockPostFirestore.generatePostData(1).map((postData) {
        return PostData(
          ownerId: owner.uid, // Map to the owner
          title: postData.title,
          description: postData.description,
          publicationTime: postData.publicationTime,
          voteScore: postData.voteScore,
        );
      }).first;

      const postPosition =
          GeoPoint(0.0001, 0); // This is < 0.1 km away from the (0,0)

      await postRepo.addPost(
        postData,
        postPosition,
      );

      // Get the expected post overview
      final expectedPosts = [
        PostOverview(
          title: postData.title,
          description: postData.description,
          votes: postData.voteScore,
          posterUsername: owner.data.username,
          commentNumber: 0,
        ),
      ];

      final actualPosts = await container.read(postOverviewProvider.future);

      expect(actualPosts, expectedPosts);
    });

    test("Throws an exception when the owner of a post is not found", () async {
      // Add the post to the database
      final postData = mockPostFirestore.generatePostData(1).first;

      await postRepo.addPost(
        postData,
        userPosition,
      );

      expect(
        container.read(postOverviewProvider.future),
        throwsA(isA<Exception>()),
      );
    });

    test("Multiple near posts with multiple owners returned correctly",
        () async {
      const nbOwners = 3;
      const nbPosts = 10;

      // Add the post owners to the database
      final owners = mockUserFirestore.generateUserFirestore(nbOwners);
      for (final owner in owners) {
        await userRepo.setUser(owner.uid, owner.data);
      }

      // Add the posts to the database
      final postDatas = mockPostFirestore
          .generatePostData(nbPosts)
          .mapIndexed(
            (index, element) => PostData(
              ownerId: owners[index % nbOwners].uid, // Map to an owner
              title: element.title,
              description: element.description,
              publicationTime: element.publicationTime,
              voteScore: element.voteScore,
            ),
          )
          .toList();

      // The 6 first posts are under 100m away from the user and are the ones expected
      const nbPostsInRange = 6;
      final postPositions = List.generate(nbPosts, (i) {
        return GeoPoint(0.0001 + i * 0.0001, 0.0001 + i * 0.0001);
      });

      // Add the posts to the database
      for (var i = 0; i < postDatas.length; i++) {
        await postRepo.addPost(
          postDatas[i],
          postPositions[i],
        );
      }

      // Get the expected post overviews
      final expectedPosts = postDatas.getRange(0, nbPostsInRange).map((data) {
        final owner = owners.firstWhere(
          (user) => user.uid == data.ownerId,
          orElse: () => throw Exception("Owner not found"), // Should not happen
        );

        return PostOverview(
          title: data.title,
          description: data.description,
          votes: data.voteScore,
          posterUsername: owner.data.username,
          commentNumber: 0,
        );
      }).toList();

      final actualPosts = await container.read(postOverviewProvider.future);

      expect(actualPosts, expectedPosts);
    });
  });
}
