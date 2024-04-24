import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home_content/feed/post_card/post_card.dart";
import "package:proxima/views/home_content/feed/post_feed.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/post/post_page.dart";
import "package:proxima/views/pages/post/post_page_widget/bottom_bar_add_comment.dart";
import "package:proxima/views/pages/post/post_page_widget/complete_post_widget.dart";

import "../../../mocks/providers/provider_homepage.dart";
import "../../../mocks/providers/provider_post_page.dart";

void main() {
  late ProviderScope nonEmptyHomePageWidget;
  late ProviderScope emptyPostPageWidget;

  setUp(() async {
    nonEmptyHomePageWidget = nonEmptyHomePageProvider;
    emptyPostPageWidget = emptyPostPageProvider;
  });

  testWidgets("Check navigation to post page and comeback to feed",
      (tester) async {
    await tester.pumpWidget(nonEmptyHomePageWidget);
    await tester.pumpAndSettle();

    // Tap of the first post
    await tester.tap(find.byKey(PostCard.postCardKey).first);
    await tester.pumpAndSettle();

    // Check if the post page is displayed
    final homePage = find.byType(CompletePostWidget);
    expect(homePage, findsOneWidget);

    // Tap on the back button
    await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
    await tester.pumpAndSettle();

    // Check if the feed is displayed
    final postFeed = find.byType(PostFeed);
    expect(postFeed, findsOneWidget);
  });

  group("Widgets display", () {
    testWidgets("Check non-comment widgets are displayed", (tester) async {
      await tester.pumpWidget(emptyPostPageWidget);
      await tester.pumpAndSettle();

      // Check if the post is displayed
      final completePost = find.byType(PostPage);
      expect(completePost, findsOneWidget);

      //Check that the post distance is displayed
      final postDistance = find.byKey(PostPage.postDistanceKey);
      expect(postDistance, findsOneWidget);

      //Check that the complete post widget is displayed
      final completePostWidget = find.byKey(PostPage.completePostWidgetKey);
      expect(completePostWidget, findsOneWidget);

      //Check that the post title is displayed
      final postTitle = find.byKey(CompletePostWidget.postTitleKey);
      expect(postTitle, findsOneWidget);

      //Check that the post description is displayed
      final postDescription = find.byKey(CompletePostWidget.postDescriptionKey);
      expect(postDescription, findsOneWidget);

      //Check that the post vote widget is displayed
      final postVoteWidget = find.byKey(CompletePostWidget.postVoteWidgetKey);
      expect(postVoteWidget, findsOneWidget);

      //Check the userbar is displayed
      final postUserBar = find.byKey(CompletePostWidget.postUserBarKey);
      expect(postUserBar, findsOneWidget);

      //Check that the comment list widget is displayed
      final commentListWidget = find.byKey(PostPage.commentListWidgetKey);
      expect(commentListWidget, findsOneWidget);

      //Check that the bottom bar add comment widget is displayed
      final bottomBarAddComment = find.byKey(PostPage.bottomBarAddCommentKey);
      expect(bottomBarAddComment, findsOneWidget);

      //Check that the comment user avatar is displayed
      final commentUserAvatar =
          find.byKey(BottomBarAddComment.commentUserAvatarKey);
      expect(commentUserAvatar, findsOneWidget);

      //Check that the add comment text field is displayed
      final addCommentTextField =
          find.byKey(BottomBarAddComment.addCommentTextFieldKey);
      expect(addCommentTextField, findsOneWidget);

      //Check that the post comment button is displayed
      final postCommentButton =
          find.byKey(BottomBarAddComment.postCommentButtonKey);
      expect(postCommentButton, findsOneWidget);
    });
  });
}
