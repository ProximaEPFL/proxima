import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home_content/feed/post_card/post_card.dart";
import "package:proxima/views/home_content/feed/post_feed.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";

import "../../../mocks/data/post_overview.dart";
import "../../../mocks/providers/provider_homepage.dart";

void main() {
  late ProviderScope nonEmptyHomePageWidget;
  late ProviderScope emptyHomePageWidget;
  late ProviderScope loadingHomePageWidget;

  setUp(() async {
    nonEmptyHomePageWidget = nonEmptyHomePageProvider;
    emptyHomePageWidget = emptyHomePageProvider;

    loadingHomePageWidget = loadingHomePageProvider;
  });

  group("Widgets display", () {
    testWidgets("Display top bar", (tester) async {
      await tester.pumpWidget(nonEmptyHomePageWidget);
      await tester.pumpAndSettle();

      // Check that the home page is displayed
      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);

      // Check that the top bar is displayed
      final topBar = find.byKey(AppTopBar.homeTopBarKey);
      expect(topBar, findsOneWidget);

      //Check profile picture is displayed
      final profilePicture = find.byKey(AppTopBar.profilePictureKey);
      expect(profilePicture, findsOneWidget);
    });

    testWidgets("Display feed", (tester) async {
      await tester.pumpWidget(nonEmptyHomePageWidget);
      await tester.pumpAndSettle();

      //Check sort option list is displayed
      final feedSortOptionList = find.byKey(PostFeed.feedSortOptionKey);
      expect(feedSortOptionList, findsOneWidget);

      // Check that the posts are displayed
      final postWidget = find.byKey(PostCard.postCardKey);
      expect(postWidget, findsExactly(testPosts.length));

      //Check that the posts title are displayed
      final postTitle = find.byKey(PostCard.postCardTitleKey);
      expect(postTitle, findsExactly(testPosts.length));

      //Check that the posts description are displayed
      final postDescription = find.byKey(PostCard.postCardDescriptionKey);
      expect(postDescription, findsExactly(testPosts.length));

      //Check that the posts votes are displayed
      final postVotes = find.byKey(PostCard.postCardVotesKey);
      expect(postVotes, findsExactly(testPosts.length));

      //Check that the number of posts comments are displayed
      final postComments = find.byKey(PostCard.postCardCommentsKey);
      expect(postComments, findsExactly(testPosts.length));

      //Check that the posts user card are displayed
      final postUser = find.byKey(PostCard.postCardUserKey);
      expect(postUser, findsExactly(testPosts.length));
    });

    testWidgets("Display text and refresh button when feed is empty",
        (tester) async {
      await tester.pumpWidget(emptyHomePageWidget);
      await tester.pumpAndSettle();

      //Check empty post message is displayed
      final emptyPostMessage = find.byKey(PostFeed.emptyfeedKey);
      expect(emptyPostMessage, findsOneWidget);

      // Check that the refresh button is displayed
      final refreshButton = find.byKey(PostFeed.refreshButtonKey);
      expect(refreshButton, findsOneWidget);

      //Check the new post button text is displayed
      final newPostButtonText = find.byKey(PostFeed.newPostButtonTextKey);
      expect(newPostButtonText, findsOneWidget);
    });

    testWidgets("Display bottom bar", (tester) async {
      await tester.pumpWidget(emptyHomePageWidget);
      await tester.pumpAndSettle();

      // Check that the bottom bar is displayed
      final bottomBar = find.byKey(NavigationBottomBar.navigationBottomBarKey);
      expect(bottomBar, findsOneWidget);

      expect(
        find.descendant(
          of: bottomBar,
          matching: find.byType(NavigationDestination),
        ),
        findsExactly(NavigationbarRoutes.values.length),
      );
    });

    testWidgets(
      "Display circular value on loading",
      (tester) async {
        await tester.pumpWidget(loadingHomePageWidget);

        // Check that the home page is displayed
        final homePage = find.byType(HomePage);
        expect(homePage, findsOneWidget);

        // Check that the circular progress indicator is displayed
        final progressIndicator = find.byType(
          CircularProgressIndicator,
        );
        expect(progressIndicator, findsOneWidget);
      },
    );
  });
}
