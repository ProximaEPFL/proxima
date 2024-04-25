import "package:collection/collection.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/home_view_model.dart";

import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/data/post_data.dart";
import "../mocks/services/mock_geo_location_service.dart";
import "../mocks/services/mock_post_repository_service.dart";
import "../mocks/services/mock_user_repository_service.dart";

void main() {
  group("Post Overview Provider unit testing", () {
    late MockGeoLocationService geoLocationService;
    late PostRepositoryService postRepository;
    late UserRepositoryService userRepository;

    late ProviderContainer container;

    setUp(() {
      geoLocationService = MockGeoLocationService();
      postRepository = MockPostRepositoryService();
      userRepository = MockUserRepositoryService();

      container = ProviderContainer(
        overrides: [
          geoLocationServiceProvider.overrideWithValue(
            geoLocationService,
          ),
          postRepositoryProvider.overrideWithValue(
            postRepository,
          ),
          userRepositoryProvider.overrideWithValue(
            userRepository,
          ),
        ],
      );
    });

    test("No posts are returned when no posts returned by the repository",
        () async {
      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition0,
      );
      when(
        postRepository.getNearPosts(
          userPosition0,
          HomeViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => [],
      );

      final posts = await container.read(postOverviewProvider.future);

      expect(posts, isEmpty);
    });

    test(
        "Post is returned correctly when single post is returned by the repository",
        () async {
      final owner = FirestoreUserGenerator.generateUserFirestore(1)[0];
      final postData = PostDataGenerator.generatePostData(1)
          .map(
            (postData) => PostData(
              ownerId: owner.uid,
              title: postData.title,
              description: postData.description,
              publicationTime: postData.publicationTime,
              voteScore: postData.voteScore,
            ),
          )
          .toList()[0];
      final post =
          FirestorePostGenerator().createPostAt(postData, userPosition0);

      when(userRepository.getUser(post.data.ownerId)).thenAnswer(
        (_) async => owner,
      );

      final expectedPosts = [
        PostOverview(
          postId: post.id,
          title: post.data.title,
          description: post.data.description,
          voteScore: post.data.voteScore,
          commentNumber: 0,
          ownerDisplayName: owner.data.displayName,
        ),
      ];

      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition0,
      );
      when(
        postRepository.getNearPosts(
          userPosition0,
          HomeViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => [post],
      );
      when(userRepository.getUser(post.data.ownerId)).thenAnswer(
        (_) async => owner,
      );

      final actualPosts = await container.read(postOverviewProvider.future);

      expect(actualPosts, expectedPosts);
    });

    test(
      "Posts are returned correctly when multiple posts are returned by the repository with all posts corresponding to the same owner",
      () async {
        // Generate the data for the test
        final owner = FirestoreUserGenerator.generateUserFirestore(1)[0];
        final postsData = PostDataGenerator.generatePostData(10)
            .map(
              (postData) => PostData(
                ownerId: owner.uid,
                title: postData.title,
                description: postData.description,
                publicationTime: postData.publicationTime,
                voteScore: postData.voteScore,
              ),
            )
            .toList();

        final posts = postsData.map((data) {
          return FirestorePostGenerator().createPostAt(data, userPosition0);
        }).toList();

        final expectedPosts = posts.map((post) {
          final postOverview = PostOverview(
            postId: post.id,
            title: post.data.title,
            description: post.data.description,
            voteScore: post.data.voteScore,
            commentNumber: 0,
            ownerDisplayName: owner.data.displayName,
          );

          return postOverview;
        });

        // Mock the repository calls
        when(userRepository.getUser(posts[0].data.ownerId)).thenAnswer(
          (_) async => owner,
        );

        when(geoLocationService.getCurrentPosition()).thenAnswer(
          (_) async => userPosition0,
        );
        when(
          postRepository.getNearPosts(
            userPosition0,
            HomeViewModel.kmPostRadius,
          ),
        ).thenAnswer(
          (_) async => posts,
        );

        // Check the actual posts
        final actualPosts = await container.read(postOverviewProvider.future);

        expect(actualPosts, expectedPosts);
      },
    );

    test(
      "Posts are returned correctly when multiple posts are returned by the repository with all posts corresponding to different owners",
      () async {
        const numberOfPosts = 10;

        // Generate the data for the test
        final owners =
            FirestoreUserGenerator.generateUserFirestore(numberOfPosts);
        final postsData =
            PostDataGenerator.generatePostData(numberOfPosts).mapIndexed(
          (index, element) => PostData(
            ownerId: owners[index].uid,
            title: element.title,
            description: element.description,
            publicationTime: element.publicationTime,
            voteScore: element.voteScore,
          ),
        );

        final posts = postsData.map((data) {
          return FirestorePostGenerator().createPostAt(data, userPosition0);
        }).toList();

        final expectedPosts = posts.mapIndexed((index, post) {
          final postOverview = PostOverview(
            postId: post.id,
            title: post.data.title,
            description: post.data.description,
            voteScore: post.data.voteScore,
            commentNumber: 0,
            ownerDisplayName: owners[index].data.displayName,
          );

          return postOverview;
        });

        // Mock the repository calls
        for (var i = 0; i < numberOfPosts; i++) {
          when(userRepository.getUser(posts[i].data.ownerId)).thenAnswer(
            (_) async => owners[i],
          );
        }

        when(geoLocationService.getCurrentPosition()).thenAnswer(
          (_) async => userPosition0,
        );
        when(
          postRepository.getNearPosts(
            userPosition0,
            HomeViewModel.kmPostRadius,
          ),
        ).thenAnswer(
          (_) async => posts,
        );

        // Check the actual posts
        final actualPosts = await container.read(postOverviewProvider.future);

        expect(actualPosts, expectedPosts);
      },
    );

    test("New posts are exposed correctly on refresh", () async {
      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition0,
      );
      when(
        postRepository.getNearPosts(
          userPosition0,
          HomeViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => [],
      );

      // Query the posts a first time
      final postBeforeRefresh =
          await container.read(postOverviewProvider.future);
      expect(postBeforeRefresh, []);

      // Simulate a new post being added
      final owner = FirestoreUserGenerator.generateUserFirestore(1)[0];
      final postData = PostDataGenerator.generatePostData(1)
          .map(
            (postData) => PostData(
              ownerId: owner.uid,
              title: postData.title,
              description: postData.description,
              publicationTime: postData.publicationTime,
              voteScore: postData.voteScore,
            ),
          )
          .toList()[0];
      final post =
          FirestorePostGenerator().createPostAt(postData, userPosition0);

      final expectedPosts = [
        PostOverview(
          postId: post.id,
          title: post.data.title,
          description: post.data.description,
          voteScore: post.data.voteScore,
          commentNumber: 0,
          ownerDisplayName: owner.data.displayName,
        ),
      ];

      when(
        postRepository.getNearPosts(
          userPosition0,
          HomeViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => [post],
      );
      when(userRepository.getUser(post.data.ownerId)).thenAnswer(
        (_) async => owner,
      );

      // Refresh the posts
      await container.read(postOverviewProvider.notifier).refresh();

      // Check the actual posts
      final postAfterRefresh =
          await container.read(postOverviewProvider.future);

      expect(postAfterRefresh, expectedPosts);
    });

    test("Error is exposed correctly on refresh", () async {
      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition0,
      );

      const expectedErrorMessage = "Error while fetching posts";
      when(
        postRepository.getNearPosts(
          userPosition0,
          HomeViewModel.kmPostRadius,
        ),
      ).thenThrow(Exception(expectedErrorMessage));

      // Refresh the posts
      await container.read(postOverviewProvider.notifier).refresh();

      // Check the actual posts
      final asyncPosts = container.read(postOverviewProvider);

      expect(
        asyncPosts,
        isA<AsyncError>().having(
          (error) => error.error.toString(),
          "message",
          "Exception: $expectedErrorMessage",
        ),
      );
    });
  });
}
