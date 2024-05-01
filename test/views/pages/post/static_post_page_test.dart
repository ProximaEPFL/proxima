import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:intl/intl.dart";
import "package:proxima/views/home_content/feed/post_card/post_card.dart";
import "package:proxima/views/home_content/feed/post_card/user_bar_widget.dart";
import "package:proxima/views/home_content/feed/post_feed.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/post/post_page.dart";
import "package:proxima/views/pages/post/post_page_widget/bottom_bar_add_comment.dart";
import "package:proxima/views/pages/post/post_page_widget/comment_post_widget.dart";
import "package:proxima/views/pages/post/post_page_widget/complete_post_widget.dart";
import "package:timeago/timeago.dart";

import "../../../mocks/data/post_comment.dart";
import "../../../mocks/data/post_overview.dart";
import "../../../mocks/providers/provider_homepage.dart";
import "../../../mocks/providers/provider_post_page.dart";

void main() {
  late ProviderScope nonEmptyHomePageWidget;
  late ProviderScope emptyPostPageWidget;
  late ProviderScope nonEmptyPostPageWidget;

  setUp(() async {
    nonEmptyHomePageWidget = nonEmptyHomePageProvider;
    emptyPostPageWidget = emptyPostPageProvider;
    nonEmptyPostPageWidget = nonEmptyPostPageProvider;
  });

  testWidgets("Check navigation to post page and comeback to feed",
      (tester) async {
    await tester.pumpWidget(nonEmptyHomePageWidget);
    await tester.pumpAndSettle();

    // Tap of the first post
    await tester.tap(find.byKey(PostCard.postCardKey).first);
    await tester.pumpAndSettle();

    // Check if the post page is displayed, with the correct title
    expect(find.byType(CompletePostWidget), findsOneWidget);
    expect(find.text(testPosts.first.title), findsAtLeastNWidgets(1));

    // Tap on the back button
    await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
    await tester.pumpAndSettle();

    // Check if the feed is displayed
    final postFeed = find.byType(PostFeed);
    expect(postFeed, findsOneWidget);
  });

  group("Widgets display", () {
    testWidgets("Check displayed post information", (tester) async {
      await tester.pumpWidget(emptyPostPageWidget);
      await tester.pumpAndSettle();

      final post = testPosts.first;

      //Check that the complete post widget is displayed
      final completePostWidget = find.byKey(PostPage.completePostWidgetKey);
      expect(completePostWidget, findsOneWidget);

      //Check that the post title is displayed
      final postTitle = find.byKey(CompletePostWidget.postTitleKey);
      expect(postTitle, findsOneWidget);
      final postTitleWidget = tester.widget(postTitle);
      expect(
        postTitleWidget is Text && postTitleWidget.data == post.title,
        true,
      );

      //Check that the post description is displayed
      final postDescription = find.byKey(CompletePostWidget.postDescriptionKey);
      expect(postDescription, findsOneWidget);
      final postDescriptionWidget = tester.widget(postDescription);
      expect(
        postDescriptionWidget is Text &&
            postDescriptionWidget.data == post.description,
        true,
      );

      //Check that the post vote widget is displayed
      final postVote = find.byKey(CompletePostWidget.postVoteWidgetKey);
      expect(postVote, findsOneWidget);

      //Check the userbar is displayed
      final postUserBar = find.byKey(CompletePostWidget.postUserBarKey);
      expect(postUserBar, findsOneWidget);

      //Check that the owner display name is displayed
      final postUserBarDisplayNameTextWidget = tester.widget(
        find.descendant(
          of: postUserBar,
          matching: find.byKey(UserBarWidget.displayNameTextKey),
        ),
      );

      expect(
        postUserBarDisplayNameTextWidget is Text &&
            postUserBarDisplayNameTextWidget.data == post.ownerDisplayName,
        true,
      );

      //Check that the publication time is displayed
      final postUserBarTimestampTextWidget = tester.widget(
        find.descendant(
          of: postUserBar,
          matching: find.byKey(UserBarWidget.timestampTextKey),
        ),
      );

      expect(
        postUserBarTimestampTextWidget is Text &&
            postUserBarTimestampTextWidget.data ==
                format(post.publicationTime.toDate(), locale: "en_short"),
        true,
      );

      // Check Tooltip message
      final tooltip = find.byType(Tooltip);
      expect(tooltip, findsOneWidget);

      final tooltipWidget = tester.widget(tooltip);
      expect(tooltipWidget is Tooltip, true);

      final tooltipMessage = (tooltipWidget as Tooltip).message;
      expect(
        tooltipMessage,
        DateFormat("EEEE, MMMM d, yyyy HH:mm 'UTC'z")
            .format(post.publicationTime.toDate().toUtc()),
      );
    });

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

    testWidgets("Check comments are displayed", (tester) async {
      await tester.pumpWidget(nonEmptyPostPageWidget);
      await tester.pumpAndSettle();

      // Check if the post is displayed
      final completePost = find.byType(PostPage);
      expect(completePost, findsOneWidget);

      //Check that comment list widget is displayed
      final commentListWidget = find.byKey(PostPage.commentListWidgetKey);
      expect(commentListWidget, findsOneWidget);

      //Check that we have the right number of comments
      final commentList = find.byKey(CommentPostWidget.commentWidgetKey);
      expect(commentList, findsNWidgets(testComments.length));

      //Check that the comment user widgets are displayed
      final commentUserAvatar =
          find.byKey(CommentPostWidget.commentUserWidgetKey);
      expect(commentUserAvatar, findsNWidgets(testComments.length));

      //Check that the username are displayed
      final Iterable<Text> displayNameWidgets = tester.widgetList<Text>(
        find.descendant(
          of: find.byKey(CommentPostWidget.commentUserWidgetKey),
          matching: find.byKey(UserBarWidget.displayNameTextKey),
        ),
      );

      expect(displayNameWidgets.length, testComments.length);

      //Check the displayed usernames are correct
      final expectedUsernames =
          testComments.map((comment) => comment.ownerDisplayName).toList();
      final actualUsernames =
          displayNameWidgets.map((textWidget) => textWidget.data).toList();

      expect(actualUsernames, expectedUsernames);

      //Check that the comment content are displayed
      final Iterable<Text> commentWidgets = tester
          .widgetList<Text>(find.byKey(CommentPostWidget.commentContentKey));
      expect(commentWidgets.length, testComments.length);

      //Check the comment content displayed information
      final expectedCommentContents =
          testComments.map((comment) => comment.content).toList();
      final actualCommentContents =
          commentWidgets.map((textWidget) => textWidget.data).toList();

      expect(actualCommentContents, expectedCommentContents);
    });
  });
}
