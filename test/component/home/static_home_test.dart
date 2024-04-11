import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/home_content/feed/post_card/post_card.dart";
import "package:proxima/views/home_content/feed/post_feed.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/pages/home/home_page.dart";

import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";
import "../../viewmodels/mock_home_view_model.dart";
import "../utils/mock_data/home/mock_posts.dart";

void main() {
  final homePageWidget = ProviderScope(
    overrides: [
      postOverviewProvider.overrideWith(
        () => MockHomeViewModel(
          build: () async => testPosts,
        ),
      ),
    ],
    child: const MaterialApp(
      title: "Proxima",
      home: HomePage(),
    ),
  );

  final emptyHomePageWidget = ProviderScope(
    overrides: [
      postOverviewProvider.overrideWith(
        () => MockHomeViewModel(),
      ),
    ],
    child: const MaterialApp(
      title: "Proxima",
      home: HomePage(),
    ),
  );

  final loadingHomePageWidget = ProviderScope(
    overrides: [
      postOverviewProvider.overrideWith(
        () => MockHomeViewModel(
          build: () {
            // Future.any([]) will never complete and simulate a loading state
            return Future.any([]);
          },
        ),
      ),
    ],
    child: const MaterialApp(
      title: "Proxima",
      home: HomePage(),
    ),
  );

  testWidgets("static home display top and bottom bar", (tester) async {
    await tester.pumpWidget(homePageWidget);
    await tester.pumpAndSettle();

    // Check that the home page is displayed
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

    // Check that the top bar is displayed
    final topBar = find.byKey(AppTopBar.homeTopBarKey);
    expect(topBar, findsOneWidget);

    //Check sort option list is displayed
    final feedSortOptionList = find.byKey(PostFeed.feedSortOptionKey);
    expect(feedSortOptionList, findsOneWidget);

    //Check profile picture is displayed
    final profilePicture = find.byKey(AppTopBar.profilePictureKey);
    expect(profilePicture, findsOneWidget);

    // Check that the bottom bar is displayed
    final bottomBar = find.byKey(NavigationBottomBar.navigationBottomBarKey);
    expect(bottomBar, findsOneWidget);

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

    //Check that the posts comments are displayed
    final postComments = find.byKey(PostCard.postCardCommentsKey);
    expect(postComments, findsExactly(testPosts.length));

    //Check that the posts user card are displayed
    final postUser = find.byKey(PostCard.postCardUserKey);
    expect(postUser, findsExactly(testPosts.length));
  });

  testWidgets("static home display no post text", (tester) async {
    await tester.pumpWidget(emptyHomePageWidget);
    await tester.pumpAndSettle();

    // Check that the home page is displayed
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

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

  testWidgets(
      "check correct number of navigation bottom bar elements are displayed",
      (tester) async {
    await tester.pumpWidget(emptyHomePageWidget);
    await tester.pumpAndSettle();

    // Check that the home page is displayed
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

    //Click on the middle element of the bottombar
    final bottomBar = find.byKey(NavigationBottomBar.navigationBottomBarKey);
    expect(
      find.descendant(
        of: bottomBar,
        matching: find.byType(NavigationDestination),
      ),
      findsExactly(NavigationbarRoutes.values.length),
    );
  });

  testWidgets(
    "static home display circular value on loading",
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
}
