import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/comment/comment_firestore.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/database/comment_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";

import "../../mocks/data/firestore_comment.dart";
import "../../mocks/data/geopoint.dart";
import "../../mocks/data/post_data.dart";

void main() {
  group("Testing comment repository", () {
    late FakeFirebaseFirestore fakeFirestore;
    late PostRepositoryService postRepository;
    late CommentRepositoryService commentRepository;

    late PostIdFirestore postId;
    late CollectionReference<Map<String, dynamic>> commentsSubCollection;
    late DocumentReference<Map<String, dynamic>> postDocument;
    late CommentFirestoreGenerator commentGenerator;

    Future<void> addComment(CommentFirestore comment) async {
      await commentsSubCollection
          .doc(comment.id.value)
          .set(comment.data.toDbData());

      await postDocument.update({
        PostData.commentCountField: FieldValue.increment(1),
      });
    }

    Future<List<CommentFirestore>> addComments(int number) async {
      final comments = <CommentFirestore>[];

      for (var i = 0; i < number; i++) {
        final comment = commentGenerator.createRandomComment();
        await addComment(comment);
        comments.add(comment);
      }

      return comments;
    }

    /// The setup add a single post with no comments
    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      commentRepository = CommentRepositoryService(
        firestore: fakeFirestore,
      );
      postRepository = PostRepositoryService(
        firestore: fakeFirestore,
      );

      final postData = PostDataGenerator().postData;

      postId = await postRepository.addPost(postData, userPosition0);

      postDocument = fakeFirestore
          .collection(
            PostFirestore.collectionName,
          )
          .doc(postId.value);

      commentsSubCollection = postDocument.collection(
        CommentFirestore.subCollectionName,
      );

      commentGenerator = CommentFirestoreGenerator();
    });

    group("getting comments", () {
      test("should return an empty list if there are no comments", () async {
        final comments = await commentRepository.getComments(postId);

        expect(comments, isEmpty);
      });

      test(
          "should return the comments of a post when there are multiple comments",
          () async {
        final comments = await addComments(5);

        final actualComments = await commentRepository.getComments(postId);

        expect(actualComments, unorderedEquals(comments));
      });
    });

    group("adding comments", () {
      test("should add a single comment to a post", () async {
        final commentData = commentGenerator.createRandomComment().data;

        final commentId = await commentRepository.addComment(
          postId,
          commentData,
        );

        final expectedComment = CommentFirestore(
          id: commentId,
          data: commentData,
        );

        // Check that the comment was added correctly
        final commentDoc =
            await commentsSubCollection.doc(commentId.value).get();
        final actualComment = CommentFirestore.fromDb(commentDoc);

        expect(actualComment, equals(expectedComment));

        // Check that the comment count was updated correctly
        final postDoc = await postDocument.get();
        final post = PostFirestore.fromDb(postDoc);

        expect(post.data.commentCount, equals(1));
      });

      test("should add comment to a post when there are already comments",
          () async {
        const alreadyPresentCommentsCount = 5;
        final alreadyPresentComments =
            await addComments(alreadyPresentCommentsCount);

        final commentData = commentGenerator.createRandomComment().data;

        final commentId = await commentRepository.addComment(
          postId,
          commentData,
        );

        final expectedNewComment = CommentFirestore(
          id: commentId,
          data: commentData,
        );

        // Check that the comment was added correctly
        final actualCommentQuery = await commentsSubCollection.get();
        final actualComments = actualCommentQuery.docs
            .map((doc) => CommentFirestore.fromDb(doc))
            .toList();

        expect(
          actualComments,
          unorderedEquals(alreadyPresentComments + [expectedNewComment]),
        );

        // Check that the comment count was updated correctly
        final postDoc = await postDocument.get();
        final post = PostFirestore.fromDb(postDoc);

        expect(post.data.commentCount, equals(alreadyPresentCommentsCount + 1));
      });
    });

    group("deleting comments", () {
      test("should delete a comment from a post with single comment", () async {
        final comment = await addComments(1);

        final commentId = comment.first.id;

        await commentRepository.deleteComment(postId, commentId);

        // Check that the comment was deleted
        final actualCommentsQuerySnap = await commentsSubCollection.get();
        expect(actualCommentsQuerySnap.docs, isEmpty);

        // Check that the comment count was updated correctly
        final postDoc = await postDocument.get();
        final post = PostFirestore.fromDb(postDoc);

        expect(post.data.commentCount, equals(0));
      });

      test("should delete a comment from a post with multiple comments",
          () async {
        const alreadyPresentCommentsCount = 5;

        final comments = await addComments(alreadyPresentCommentsCount);

        // Delete the third comment
        final commentToDeleteId = comments[2].id;
        await commentRepository.deleteComment(postId, commentToDeleteId);

        final expectedComments =
            comments.where((c) => c.id != commentToDeleteId);

        // Check that the comment was deleted
        final actualCommentsQuerySnap = await commentsSubCollection.get();
        final actualComments = actualCommentsQuerySnap.docs
            .map((doc) => CommentFirestore.fromDb(doc))
            .toList();

        expect(
          actualComments,
          unorderedEquals(expectedComments),
        );

        // Check that the comment count was updated correctly
        final postDoc = await postDocument.get();
        final post = PostFirestore.fromDb(postDoc);

        expect(post.data.commentCount, equals(alreadyPresentCommentsCount - 1));
      });

      test("should do nothing if the comment does not exist", () async {
        await addComments(5);

        const commentId = CommentIdFirestore(value: "non_existent_comment_id");

        await commentRepository.deleteComment(postId, commentId);

        // Check that the comments were not deleted
        final actualCommentsQuerySnap = await commentsSubCollection.get();
        expect(actualCommentsQuerySnap.docs.length, equals(5));

        // Check that the comment count was not updated
        final postDoc = await postDocument.get();
        final post = PostFirestore.fromDb(postDoc);

        expect(post.data.commentCount, equals(5));
      });
    });
  });
}
