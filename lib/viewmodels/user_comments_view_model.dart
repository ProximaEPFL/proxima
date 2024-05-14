import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_id_firestore.dart";
import "package:proxima/models/ui/user_comment_details.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/services/database/user_comment_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/posts_feed_view_model.dart";

typedef UserCommentsState = List<UserCommentDetails>;

class UserCommentViewModel extends AutoDisposeAsyncNotifier<UserCommentsState> {
  UserCommentViewModel();

  @override
  Future<UserCommentsState> build() async {
    final userCommentRepository =
        ref.watch(userCommentRepositoryServiceProvider);
    final user = ref.watch(validLoggedInUserIdProvider);

    final commentsFirestore = await userCommentRepository.getUserComments(user);
    final comments = commentsFirestore.map((comment) {
      final userComment = UserCommentDetails(
        userCommentId: comment.id,
        description: comment.data.content,
        parentPostId: comment.data.parentPostId,
        commentId: comment.data.commentId,
      );
      return userComment;
    }).toList();

    return comments;
  }

  /// Delete the comment with the given [commentId] from the database
  /// and refresh the state of this viewmodel (list of user comments).
  Future<void> deleteComment(
    UserCommentIdFirestore userComment,
    PostIdFirestore postId,
    CommentIdFirestore commentId,
  ) async {
    final userCommentRepository =
        ref.watch(userCommentRepositoryServiceProvider);
    final commentRepository = ref.watch(commentRepositoryServiceProvider);
    final user = ref.watch(validLoggedInUserIdProvider);
    await userCommentRepository.deleteUserComment(user, userComment);

    // Not awaited, will show loading for user (faster user feedback)
    refresh();

    // Delete the comment from the post
    await commentRepository.deleteComment(postId, commentId);

    // Refresh the home feed after post deletion
    ref.read(postsFeedViewModelProvider.notifier).refresh();
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
