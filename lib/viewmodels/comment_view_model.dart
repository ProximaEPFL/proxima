import "dart:async";

import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/comment_post.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";

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

      return CommentPost(
        content: commentFirestore.data.content,
        ownerDisplayName: owner.data.displayName,
        publicationDate: DateTime.fromMillisecondsSinceEpoch(
          commentFirestore.data.publicationTime.millisecondsSinceEpoch,
        ),
      );
    }).toList();

    return comments;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}
