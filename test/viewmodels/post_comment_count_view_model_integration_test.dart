import "package:collection/collection.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/viewmodels/comments_view_model.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/post_comment_count_view_model.dart";
import "package:proxima/viewmodels/user_comments_view_model.dart";

import "../mocks/data/comment_data.dart";
import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/services/mock_geo_location_service.dart";
import "../mocks/services/setup_firebase_mocks.dart";
import "../utils/delay_async_func.dart";

void main() {
  late MockGeolocationService geoLocationService;
  late FakeFirebaseFirestore fakeFireStore;
  late ProviderContainer container;

  late CommentRepositoryService commentRepository;

  setUp(() {
    setupFirebaseAuthMocks();

    geoLocationService = MockGeolocationService();
    fakeFireStore = FakeFirebaseFirestore();
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) async => userPosition0,
    );

    container = ProviderContainer(
      overrides: [
        geolocationServiceProvider.overrideWithValue(geoLocationService),
        loggedInUserIdProvider.overrideWithValue(testingUserFirestoreId),
        firestoreProvider.overrideWithValue(fakeFireStore),
      ],
    );

    commentRepository = container.read(commentRepositoryServiceProvider);
  });

  Future<void> expectCommentCount(
    PostIdFirestore postId,
    int expectedCount,
  ) async {
    final actualCount = await container.read(
      postCommentCountProvider(postId).future,
    );
    expect(actualCount, equals(expectedCount));
  }

  group("Comment count refresh", () {
    const int startCommentCount = 5;
    late PostFirestore post;
    late List<CommentFirestore> comments;

    setUp(() async {
      // Create and add a post to the database
      final postGenerator = FirestorePostGenerator();
      post = postGenerator.generatePostAt(userPosition0);
      await setPostFirestore(post, fakeFireStore);

      // Create comments
      final commentDataGenerator = CommentDataGenerator();
      final commentDatas = List.generate(
        startCommentCount,
        (_) => commentDataGenerator.createMockCommentData(
          ownerId: testingUserFirestoreId,
        ),
      ).toList();

      // Add the comments to the database
      final commentIds = await Future.wait(
        commentDatas.map(
          (commentData) => commentRepository.addComment(post.id, commentData),
        ),
      );

      comments = commentIds
          .mapIndexed(
            (i, id) => CommentFirestore(id: id, data: commentDatas[i]),
          )
          .toList();
    });

    test("Refresh on comment list refresh", () async {
      await expectCommentCount(post.id, startCommentCount);

      // Add a new comment
      final newComment = CommentDataGenerator().createMockCommentData();
      await commentRepository.addComment(post.id, newComment);

      // This should not have refreshed for now
      await expectCommentCount(post.id, startCommentCount);

      // Refresh the comment list
      await container
          .read(commentsViewModelProvider(post.id).notifier)
          .refresh();
      await Future.delayed(delayNeededForAsyncFunctionExecution);

      // The comment count should now be updated
      await expectCommentCount(post.id, startCommentCount + 1);
    });

    test("Refresh on comment deletion in view-model", () async {
      await expectCommentCount(post.id, startCommentCount);

      // Delete the post
      final comment = comments.first;
      final userCommentViewModel = container.read(
        userCommentsViewModelProvider.notifier,
      );
      await userCommentViewModel.deleteComment(
        post.id,
        comment.id,
      );
      await Future.delayed(delayNeededForAsyncFunctionExecution);

      // The comment count should now be 1 less
      await expectCommentCount(post.id, startCommentCount - 1);
    });
  });
}
