import "package:cloud_firestore/cloud_firestore.dart";
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

import "../models/database/post/mock_post_data.dart";
import "../models/database/user/mock_user_data.dart";
import "../services/database/mock_post_repository_service.dart";
import "../services/database/mock_user_repository_service.dart";
import "../services/mock_geo_location_service.dart";

void main() {
  group("Post Overview Provider unit testing", () {
    late MockGeoLocationService geoLocationService;
    late PostRepositoryService postRepository;
    late UserRepositoryService userRepository;

    late ProviderContainer container;
    late MockPostFirestore mockPostFirestore;
    late MockUserFirestore mockUserFirestore;

    const point = GeoPoint(0, 0);

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

      mockPostFirestore = MockPostFirestore();
      mockUserFirestore = MockUserFirestore();
    });

    test("No posts are returned when no posts returned by the repository",
        () async {
      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => point,
      );
      when(postRepository.getNearPosts(point, kmPostRadius)).thenAnswer(
        (_) async => [],
      );

      final posts = await container.read(postOverviewProvider.future);

      expect(posts, isEmpty);
    });

    test(
        "Post is returned correctly when single post is returned by the repository",
        () async {
      final owner = mockUserFirestore.generateUserFirestore(1)[0];
      final postData = mockPostFirestore
          .generatePostData(1)
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
      final post = mockPostFirestore.createPostAt(postData, point);

      when(userRepository.getUser(post.data.ownerId)).thenAnswer(
        (_) async => owner,
      );

      final expectedPosts = [
        PostOverview(
          title: post.data.title,
          description: post.data.description,
          votes: post.data.voteScore,
          commentNumber: 0,
          posterUsername: owner.data.username,
        ),
      ];

      when(geoLocationService.getCurrentPosition()).thenAnswer(
        (_) async => point,
      );
      when(postRepository.getNearPosts(point, kmPostRadius)).thenAnswer(
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
        final owner = mockUserFirestore.generateUserFirestore(1)[0];
        final postsData = mockPostFirestore
            .generatePostData(10)
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
          return mockPostFirestore.createPostAt(data, point);
        }).toList();

        final expectedPosts = postsData.map((data) {
          return PostOverview(
            title: data.title,
            description: data.description,
            votes: data.voteScore,
            commentNumber: 0,
            posterUsername: owner.data.username,
          );
        }).toList();

        // Mock the repository calls
        when(userRepository.getUser(posts[0].data.ownerId)).thenAnswer(
          (_) async => owner,
        );

        when(geoLocationService.getCurrentPosition()).thenAnswer(
          (_) async => point,
        );
        when(postRepository.getNearPosts(point, kmPostRadius)).thenAnswer(
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
        final owners = mockUserFirestore.generateUserFirestore(numberOfPosts);
        final postsData =
            mockPostFirestore.generatePostData(numberOfPosts).mapIndexed(
                  (index, element) => PostData(
                    ownerId: owners[index].uid,
                    title: element.title,
                    description: element.description,
                    publicationTime: element.publicationTime,
                    voteScore: element.voteScore,
                  ),
                );

        final posts = postsData.map((data) {
          return mockPostFirestore.createPostAt(data, point);
        }).toList();

        final expectedPosts = postsData.mapIndexed(
          (index, data) {
            return PostOverview(
              title: data.title,
              description: data.description,
              votes: data.voteScore,
              commentNumber: 0,
              posterUsername: owners[index].data.username,
            );
          },
        );

        // Mock the repository calls
        for (var i = 0; i < numberOfPosts; i++) {
          when(userRepository.getUser(posts[i].data.ownerId)).thenAnswer(
            (_) async => owners[i],
          );
        }

        when(geoLocationService.getCurrentPosition()).thenAnswer(
          (_) async => point,
        );
        when(postRepository.getNearPosts(point, kmPostRadius)).thenAnswer(
          (_) async => posts,
        );

        // Check the actual posts
        final actualPosts = await container.read(postOverviewProvider.future);

        expect(actualPosts, expectedPosts);
      },
    );
  });
}
