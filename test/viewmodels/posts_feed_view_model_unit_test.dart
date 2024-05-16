import "package:collection/collection.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/post_details.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/services/sorting/post/post_sorting_service.dart";
import "package:proxima/viewmodels/feed_sort_options_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";

import "../mocks/data/firestore_challenge.dart";
import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/data/post_data.dart";
import "../mocks/services/mock_challenge_repository_service.dart";
import "../mocks/services/mock_geo_location_service.dart";
import "../mocks/services/mock_post_repository_service.dart";
import "../mocks/services/mock_user_repository_service.dart";

void main() {
  group("Post Overview Provider unit testing", () {
    late MockGeolocationService geoLocationService;
    late PostRepositoryService postRepository;
    late UserRepositoryService userRepository;
    late ChallengeRepositoryService challengeRepository;

    late ProviderContainer container;

    setUp(() {
      geoLocationService = MockGeolocationService();
      postRepository = MockPostRepositoryService();
      userRepository = MockUserRepositoryService();
      challengeRepository = MockChallengeRepositoryService();

      container = ProviderContainer(
        overrides: [
          geolocationServiceProvider.overrideWithValue(
            geoLocationService,
          ),
          postRepositoryServiceProvider.overrideWithValue(
            postRepository,
          ),
          userRepositoryServiceProvider.overrideWithValue(
            userRepository,
          ),
          challengeRepositoryServiceProvider.overrideWithValue(
            challengeRepository,
          ),
          loggedInUserIdProvider.overrideWithValue(testingUserFirestoreId),
        ],
      );

      when(
        challengeRepository.getChallenges(
          testingUserFirestoreId,
          userPosition0,
        ),
      ).thenAnswer(
        (_) async => [],
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
          PostsFeedViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => [],
      );

      final posts = await container.read(postsFeedViewModelProvider.future);

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
              commentCount: postData.commentCount,
            ),
          )
          .toList()[0];
      final post =
          FirestorePostGenerator().createPostAt(postData, userPosition0);

      when(userRepository.getUser(post.data.ownerId)).thenAnswer(
        (_) async => owner,
      );

      final expectedPosts = [
        PostDetails(
          postId: post.id,
          title: post.data.title,
          description: post.data.description,
          voteScore: post.data.voteScore,
          commentNumber: post.data.commentCount,
          ownerDisplayName: owner.data.displayName,
          ownerUsername: owner.data.username,
          ownerCentauriPoints: owner.data.centauriPoints,
          publicationDate: post.data.publicationTime.toDate(),
          distance: 0,
        ),
      ];

      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition0,
      );
      when(
        postRepository.getNearPosts(
          userPosition0,
          PostsFeedViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => [post],
      );
      when(userRepository.getUser(post.data.ownerId)).thenAnswer(
        (_) async => owner,
      );

      final actualPosts =
          await container.read(postsFeedViewModelProvider.future);

      expect(actualPosts, unorderedEquals(expectedPosts));
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
                commentCount: postData.commentCount,
              ),
            )
            .toList();

        final posts = postsData.map((data) {
          return FirestorePostGenerator().createPostAt(data, userPosition0);
        }).toList();

        final expectedPosts = posts.map((post) {
          final postDetails = PostDetails(
            postId: post.id,
            title: post.data.title,
            description: post.data.description,
            voteScore: post.data.voteScore,
            commentNumber: post.data.commentCount,
            ownerDisplayName: owner.data.displayName,
            ownerUsername: owner.data.username,
            ownerCentauriPoints: owner.data.centauriPoints,
            publicationDate: post.data.publicationTime.toDate(),
            distance: 0,
          );

          return postDetails;
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
            PostsFeedViewModel.kmPostRadius,
          ),
        ).thenAnswer(
          (_) async => posts,
        );

        // Check the actual posts
        final actualPosts =
            await container.read(postsFeedViewModelProvider.future);

        expect(actualPosts, unorderedEquals(expectedPosts));
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
            commentCount: element.commentCount,
          ),
        );

        final posts = postsData.map((data) {
          return FirestorePostGenerator().createPostAt(data, userPosition0);
        }).toList();

        final expectedPosts = posts.mapIndexed((index, post) {
          final postDetails = PostDetails(
            postId: post.id,
            title: post.data.title,
            description: post.data.description,
            voteScore: post.data.voteScore,
            commentNumber: post.data.commentCount,
            ownerDisplayName: owners[index].data.displayName,
            ownerUsername: owners[index].data.username,
            ownerCentauriPoints: owners[index].data.centauriPoints,
            publicationDate: post.data.publicationTime.toDate(),
            distance: 0,
          );

          return postDetails;
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
            PostsFeedViewModel.kmPostRadius,
          ),
        ).thenAnswer(
          (_) async => posts,
        );

        // Check the actual posts
        final actualPosts =
            await container.read(postsFeedViewModelProvider.future);

        expect(actualPosts, unorderedEquals(expectedPosts));
      },
    );

    test("New posts are exposed correctly on refresh", () async {
      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition0,
      );
      when(
        postRepository.getNearPosts(
          userPosition0,
          PostsFeedViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => [],
      );

      // Query the posts a first time
      final postBeforeRefresh =
          await container.read(postsFeedViewModelProvider.future);
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
              commentCount: postData.commentCount,
            ),
          )
          .toList()[0];
      final post =
          FirestorePostGenerator().createPostAt(postData, userPosition0);

      final expectedPosts = [
        PostDetails(
          postId: post.id,
          title: post.data.title,
          description: post.data.description,
          voteScore: post.data.voteScore,
          commentNumber: post.data.commentCount,
          ownerDisplayName: owner.data.displayName,
          ownerUsername: owner.data.username,
          ownerCentauriPoints: owner.data.centauriPoints,
          publicationDate: post.data.publicationTime.toDate(),
          distance: 0,
        ),
      ];

      when(
        postRepository.getNearPosts(
          userPosition0,
          PostsFeedViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => [post],
      );
      when(userRepository.getUser(post.data.ownerId)).thenAnswer(
        (_) async => owner,
      );

      // Refresh the posts
      await container.read(postsFeedViewModelProvider.notifier).refresh();

      // Check the actual posts
      final postAfterRefresh =
          await container.read(postsFeedViewModelProvider.future);

      expect(postAfterRefresh, unorderedEquals(expectedPosts));
    });

    test("Error is exposed correctly on refresh", () async {
      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition0,
      );

      const expectedErrorMessage = "Error while fetching posts";
      when(
        postRepository.getNearPosts(
          userPosition0,
          PostsFeedViewModel.kmPostRadius,
        ),
      ).thenThrow(Exception(expectedErrorMessage));

      // Refresh the posts
      await container.read(postsFeedViewModelProvider.notifier).refresh();

      // Check the actual posts
      final asyncPosts = container.read(postsFeedViewModelProvider);

      expect(
        asyncPosts,
        isA<AsyncError>().having(
          (error) => error.error.toString(),
          "message",
          "Exception: $expectedErrorMessage",
        ),
      );
    });

    test("Puts challenges on top of the list", () async {
      final generator = FirestorePostGenerator();
      final posts = generator.generatePostsAt(
        userPosition0,
        10,
      );
      final validChallenges = [
        posts[2],
        posts[5],
      ].map((post) => FirestoreChallengeGenerator.generateFromPostId(post.id));

      final challenges = [
        ...validChallenges,
        FirestoreChallengeGenerator.generateFromPostId(
          const PostIdFirestore(value: "inexistent_id"),
        ),
      ];

      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => userPosition0,
      );
      when(
        postRepository.getNearPosts(
          userPosition0,
          PostsFeedViewModel.kmPostRadius,
        ),
      ).thenAnswer(
        (_) async => posts,
      );
      for (final post in posts) {
        when(userRepository.getUser(post.data.ownerId)).thenAnswer(
          (_) async => FirestoreUserGenerator.generateUserFirestoreWithId(
            [post.data.ownerId],
          ).first,
        );
      }

      final sortOption = container.read(feedSortOptionsViewModelProvider);

      // No challenge
      final actualPostsNoChallenge = await container.read(
        postsFeedViewModelProvider.future,
      );
      final sortedPostsNoChallenge = PostSortingService().sort(
        posts,
        sortOption,
        userPosition0,
      );

      // Check the list is in correct order
      expect(
        actualPostsNoChallenge.map((p) => p.postId.value),
        equals(sortedPostsNoChallenge.map((p) => p.id.value)),
      );
      // Check no post is a challenge
      expect(actualPostsNoChallenge.any((p) => p.isChallenge), isFalse);

      // Challenges
      when(
        challengeRepository.getChallenges(
          testingUserFirestoreId,
          userPosition0,
        ),
      ).thenAnswer(
        (_) async => challenges,
      );
      await container.read(postsFeedViewModelProvider.notifier).refresh();

      final actualPosts = await container.read(
        postsFeedViewModelProvider.future,
      );

      final sortedPosts = PostSortingService().sort(
        posts,
        sortOption,
        userPosition0,
        putOnTop: challenges.map((c) => c.postId).toSet(),
      );

      // Check list is in correct order
      expect(
        actualPosts.map((p) => p.postId.value),
        equals(sortedPosts.map((p) => p.id.value)),
      );

      // Check the first validChallenges.length are challenges, and that
      // the rest are not (i.e. the challenges are on top)
      final actualPostsTop = actualPosts.take(validChallenges.length);
      final actualPostsBottom = actualPosts.skip(validChallenges.length);
      expect(actualPostsTop.any((p) => !p.isChallenge), isFalse);
      expect(actualPostsBottom.any((p) => p.isChallenge), isFalse);
    });
  });
}
