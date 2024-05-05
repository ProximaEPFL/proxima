import "dart:async";

import "package:collection/collection.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/comment_post.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";

/// This view model is used to fetch the comments of a post.
/// It fetches the comments under the post with the id [arg] and returns
/// a list of [CommentPost] objects to be displayed.
class CommentViewModel
    extends AutoDisposeFamilyAsyncNotifier<List<CommentPost>, PostIdFirestore> {
  @override
  Future<List<CommentPost>> build(PostIdFirestore arg) async {
    final commentRepository = ref.read(commentRepositoryProvider);
    final userRepository = ref.read(userRepositoryProvider);

    final commentsFirestore = await commentRepository.getComments(arg);

    final commentOwnersId =
        commentsFirestore.map((comment) => comment.data.ownerId).toSet();

    final commentOwners = await Future.wait(
      commentOwnersId.map((userId) => userRepository.getUser(userId)),
    );

    final comments = commentsFirestore.map((commentFirestore) {
      final owner = commentOwners.firstWhere(
        (user) => user.uid == commentFirestore.data.ownerId,
        // This should never be executed in practice as if the owner is not found,
        // the user repository would have already thrown an exception.
        orElse: () => throw Exception("Owner not found"),
      );

      return CommentPost.from(commentFirestore.data, owner.data);
    }).toList();

    // Sort the comments from the newest to the oldest
    final sortedComments = comments.sorted(
      (commentA, commentB) =>
          -commentA.publicationDate.compareTo(commentB.publicationDate),
    );

    return sortedComments;
  }

  /// Refreshes the list of comments under the post
  /// This will put the state in a loading state, fetch the comments
  /// and update the state with the new comments.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

final commentListProvider = AsyncNotifierProvider.autoDispose
    .family<CommentViewModel, List<CommentPost>, PostIdFirestore>(
  () => CommentViewModel(),
);
