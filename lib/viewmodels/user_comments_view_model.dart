import "package:collection/collection.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/user_comment_details.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/post_comment_count_view_model.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";

typedef UserCommentsState = List<UserCommentDetails>;

class UserCommentViewModel extends AutoDisposeAsyncNotifier<UserCommentsState> {
  UserCommentViewModel();

  @override
  Future<UserCommentsState> build() async {
    final userCommentRepository = ref.watch(commentRepositoryServiceProvider);
    final user = ref.watch(validLoggedInUserIdProvider);

    final commentsFirestore = await userCommentRepository.getUserComments(user);

    // Sort the comments from latest to oldest
    final sortedCommentsFirestore = commentsFirestore.toList().sorted(
          (commentA, commentB) => commentB.data.publicationTime
              .compareTo(commentA.data.publicationTime),
        );

    final comments = sortedCommentsFirestore.map((comment) {
      final userComment = UserCommentDetails(
        commentId: comment.id,
        parentPostId: comment.data.parentPostId,
        description: comment.data.content,
      );
      return userComment;
    }).toList();

    return comments;
  }

  /// Delete the comment with the given [postId] and [commentId]
  /// and refresh the state of this viewmodel (list of user comments).
  Future<void> deleteComment(
    PostIdFirestore postId,
    CommentIdFirestore commentId,
  ) async {
    final commentRepository = ref.watch(commentRepositoryServiceProvider);
    final user = ref.watch(validLoggedInUserIdProvider);
    await commentRepository.deleteComment(postId, commentId, user);

    // Not awaited, will show loading for user (faster user feedback)
    refresh();

    // Refresh the home feed after comment deletion, that way the comment
    // count will be updated
    ref.read(postsFeedViewModelProvider.notifier).refresh();
    // Also update the comment count for the post
    ref.read(postCommentCountProvider(postId).notifier).refresh();
  }

  /// Refresh the list of posts
  /// This will put the state of the viewmodel to loading, fetch the posts
  /// and update the state accordingly
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final userCommentsViewModelProvider =
    AutoDisposeAsyncNotifierProvider<UserCommentViewModel, UserCommentsState>(
  () => UserCommentViewModel(),
);
