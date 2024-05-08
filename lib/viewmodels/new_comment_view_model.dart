import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/new_comment_state.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// The view model for adding a new comment to a post whose
/// post id [PostIdFirestore] is provided as an argument.
class NewCommentViewModel
    extends FamilyAsyncNotifier<NewCommentState, PostIdFirestore> {
  static const String contentEmptyError = "Please fill out your comment";

  // The controller for the content of the comment
  // is kept in the view model to avoid losing the content of the comment
  // if the user navigates away from the page inadvertedly.
  final contentController = TextEditingController();

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
          contentError: contentEmptyError,
          posted: false,
        ),
      );

      return false;
    }

    return true;
  }

  /// Resets the state to be ready for adding a new comment.
  Future<void> reset() async {
    ref.invalidateSelf();
    await future;
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
    final commentRepository = ref.read(commentRepositoryProvider);

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

final newCommentStateProvider = AsyncNotifierProvider.family<
    NewCommentViewModel, NewCommentState, PostIdFirestore>(
  () => NewCommentViewModel(),
);
