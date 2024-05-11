import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/comment/comment_data.dart";
import "package:proxima/models/database/comment/comment_id_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/views/pages/post/components/new_comment/new_comment_button.dart";
import "package:proxima/views/pages/post/components/new_comment/new_comment_textfield.dart";

import "../../../mocks/data/comment_data.dart";
import "../../../mocks/data/firestore_comment.dart";
import "../../../mocks/data/firestore_user.dart";
import "../../../mocks/providers/provider_post_page.dart";
import "../../../mocks/services/mock_comment_repository_service.dart";

void main() {
  late ProviderScope fakePostPage;

  late UserIdFirestore userId;
  late CommentIdFirestore commentId;

  late MockCommentRepositoryService commentRepository;
  late CommentDataGenerator commentDataGenerator;

  group("Testing post page", () {
    setUp(() {
      commentRepository = MockCommentRepositoryService();
      commentDataGenerator = CommentDataGenerator();
      userId = testingUserFirestoreId;
      commentId = CommentFirestoreGenerator().createMockComment().id;

      fakePostPage = postPageProvider(commentRepository, userId);
    });

    testWidgets(
      "Add a valid comment on a post",
      (widgetTester) async {
        await widgetTester.pumpWidget(fakePostPage);
        await widgetTester.pumpAndSettle();

        // Add a comment
        final validContent =
            commentDataGenerator.createMockCommentData().content;

        final commentField =
            find.byKey(NewCommentTextField.addCommentTextFieldKey);
        await widgetTester.enterText(commentField, validContent);
        await widgetTester.pumpAndSettle();

        when(commentRepository.addComment(any, any))
            .thenAnswer((_) async => commentId);

        final timeBeforeAdd = Timestamp.now();

        final postButton = find.byKey(NewCommentButton.postCommentButtonKey);
        await widgetTester.tap(postButton);
        await widgetTester.pumpAndSettle();

        final timeAfterAdd = Timestamp.now();

        final CommentData capturedCommentData =
            verify(commentRepository.addComment(any, captureAny))
                .captured
                .first;

        expect(capturedCommentData.content, validContent);
        expect(capturedCommentData.ownerId, userId);
        expect(
          capturedCommentData.publicationTime.microsecondsSinceEpoch,
          greaterThanOrEqualTo(timeBeforeAdd.microsecondsSinceEpoch),
        );
        expect(
          capturedCommentData.publicationTime.microsecondsSinceEpoch,
          lessThanOrEqualTo(timeAfterAdd.microsecondsSinceEpoch),
        );
        expect(capturedCommentData.voteScore, 0);
      },
    );
  });
}
