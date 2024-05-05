import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/new_comment_state.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// The view model for adding a new comment to a post whose
/// post id [PostIdFirestore] is provided as an argument.
class NewCommentViewModel
    extends AutoDisposeFamilyAsyncNotifier<NewCommentState, PostIdFirestore> {
  static const String _contentError = "Please enter a coment";

  @override
  Future<NewCommentState> build(PostIdFirestore arg) async {
    return NewCommentState(contentError: null, posted: false);
  }

  /// Validates that the content is not empty.
  /// If it is empty, the state is updated with the appropriate error message.
  /// Returns true if the content is not empty, false otherwise.
  bool validate(String content) {
    if (content.isEmpty) {
      state = AsyncData(
        NewCommentState(
          contentError: _contentError,
          posted: false,
        ),
      );

      return false;
    }

    return true;
  }

  /// Verifies that the content is not empty, then adds a new comment to the database.
  /// If the content is empty, the state is updated with the appropriate error message.
  /// If the comment is successfully added, the state is updated with the posted flag set to true.
  /// Returns true if the comment was successfully added, false otherwise.
  Future<bool> tryAddComment(String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _tryAddComment(content));
    return state.value?.posted ?? false;
  }

  Future<NewCommentState> _tryAddComment(String content) async {
    final currentUserId = ref.read(uidProvider);
    if (currentUserId == null) {
      throw Exception("User must be logged in before creating a comment");
    }

    if (!validate(content)) {
      // not loading or error since validation failed and wrote to the state
      return state.value!;
    }

    // The parent post id is gotten from the family argument
    final postId = arg;

    final commentData = CommentData(
      content: content,
      ownerId: currentUserId,
      publicationTime: Timestamp.now(),
      voteScore: 0,
    );

    final commentRepository = ref.read(commentRepositoryProvider);
    await commentRepository.addComment(postId, commentData);

    state = AsyncData(
      NewCommentState(
        contentError: null,
        posted: true,
      ),
    );

    return state.value!;
  }
}

final newCommentStateProvider = AsyncNotifierProvider.autoDispose
    .family<NewCommentViewModel, NewCommentState, PostIdFirestore>(
  () => NewCommentViewModel(),
);
