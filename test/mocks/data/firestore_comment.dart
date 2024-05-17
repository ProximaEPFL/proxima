import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/database/user_comment/user_comment_data.dart";
import "package:proxima/models/database/user_comment/user_comment_firestore.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";

import "comment_data.dart";
import "firestore_post.dart";
import "geopoint.dart";

/// This class is responsible for generating mock data for [CommentFirestore] and [UserCommentFirestore].
class CommentFirestoreGenerator {
  int _commentId = 0;
  final CommentDataGenerator _commentDataGenerator;
  final FirestorePostGenerator _postGenerator;

  CommentFirestoreGenerator({int seed = 0})
      : _commentDataGenerator = CommentDataGenerator(seed: seed),
        _postGenerator = FirestorePostGenerator();

  /// This will add a comment to the post with the given [postId] for the user with the given [userId].
  /// It will use the [commentRepository] to add the comment.
  /// It will return the added comment and the user comment.
  Future<(CommentFirestore, UserCommentFirestore)> addComment(
    PostIdFirestore postId,
    UserIdFirestore userId,
    CommentRepositoryService commentRepository,
  ) async {
    final commentData =
        _commentDataGenerator.createMockCommentData(ownerId: userId);
    final commentId = await commentRepository.addComment(postId, commentData);

    final comment = CommentFirestore(id: commentId, data: commentData);
    final userComment = _toUserComment(comment, postId);

    return (comment, userComment);
  }

  /// This will add [number] comments to the post with the given [postId].
  /// It will use the [commentRepository] to add the comments.
  /// It will return the added comments and the user comments.
  Future<(List<CommentFirestore>, List<UserCommentFirestore>)> addComments(
    int number,
    PostIdFirestore postId,
    CommentRepositoryService commentRepository,
  ) async {
    final postComments = <CommentFirestore>[];
    final userComments = <UserCommentFirestore>[];

    for (var i = 0; i < number; i++) {
      final commentData = _commentDataGenerator.createMockCommentData();
      final commentId = await commentRepository.addComment(postId, commentData);
      final comment = CommentFirestore(id: commentId, data: commentData);
      postComments.add(comment);

      final userComment = _toUserComment(comment, postId);
      userComments.add(userComment);
    }

    return (postComments, userComments);
  }

  /// This will add [number] comments for the user with the given [userId].
  /// The comments will be added to different posts.
  /// It will use the [commentRepository] to add the comments.
  /// It will create the posts on [firestore].
  /// It will return the added comments and the user comments.
  Future<(List<CommentFirestore>, List<UserCommentFirestore>)>
      addCommentsForUser(
    int number,
    UserIdFirestore userId,
    CommentRepositoryService commentRepository,
    FirebaseFirestore firestore,
  ) async {
    final postComments = <CommentFirestore>[];
    final userComments = <UserCommentFirestore>[];

    final posts =
        await _postGenerator.addPosts(firestore, userPosition0, number);

    for (final post in posts) {
      final commentData =
          _commentDataGenerator.createMockCommentData(ownerId: userId);

      final commentId =
          await commentRepository.addComment(post.id, commentData);

      final comment = CommentFirestore(id: commentId, data: commentData);
      postComments.add(comment);

      final userComment = _toUserComment(comment, post.id);
      userComments.add(userComment);
    }

    return (postComments, userComments);
  }

  /// This will create randomly a mock [CommentFirestore].
  /// You can pass the [commentId] and [data] to be used to avoid randomness.
  CommentFirestore createMockComment({
    CommentIdFirestore? commentId,
    CommentData? data,
  }) {
    _commentId += 1;

    return CommentFirestore(
      id: commentId ?? CommentIdFirestore(value: "commentId_$_commentId"),
      data: data ?? _commentDataGenerator.createMockCommentData(),
    );
  }

  /// Converts a [CommentFirestore] to a [UserCommentFirestore].
  UserCommentFirestore _toUserComment(
    CommentFirestore comment,
    PostIdFirestore postId,
  ) {
    final userCommentData = UserCommentData(
      parentPostId: postId,
      content: comment.data.content,
    );
    return UserCommentFirestore(id: comment.id, data: userCommentData);
  }
}
