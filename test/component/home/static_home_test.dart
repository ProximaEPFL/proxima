import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/posts/home_feed.dart";
import "package:proxima/views/pages/home/posts/post_card/post_card.dart";
import "package:proxima/views/pages/home/top_bar/home_top_bar.dart";
import "../utils/mock_data/home/mock_posts.dart";

void main() {
  testWidgets("static home display top and bottom bar", (tester) async {
    final homePageWidget = ProviderScope(
      overrides: [postList.overrideWithValue(testPosts)],
      child: const MaterialApp(
        title: "Proxima",
        home: HomePage(),
      ),
    );

    await tester.pumpWidget(homePageWidget);
    await tester.pumpAndSettle();

    // Check that the home page is displayed
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

    // Check that the top bar is displayed
    final topBar = find.byKey(HomeTopBar.homeTopBarKey);
    expect(topBar, findsOneWidget);

    //Check filter dropdown is displayed
    final filterDropDown = find.byKey(HomeFeed.timelineFiltersDropDownKey);
    expect(filterDropDown, findsOneWidget);

    //Check profile picture is displayed
    final profilePicture = find.byKey(HomeTopBar.profilePictureKey);
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
    final homePageWidget = ProviderScope(
      overrides: [postList.overrideWithValue(List.empty())],
      child: const MaterialApp(
        title: "Proxima",
        home: HomePage(),
      ),
    );

    await tester.pumpWidget(homePageWidget);
    await tester.pumpAndSettle();

    // Check that the home page is displayed
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

    //Check empty post message is displayed
    final emptyPostMessage = find.byKey(HomeFeed.emptyHomeFeedKey);
    expect(emptyPostMessage, findsOneWidget);
  });
}
