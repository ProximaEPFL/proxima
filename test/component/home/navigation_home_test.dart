import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/leading_back_button/leading_back_button.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/posts/home_feed.dart";
import "package:proxima/views/pages/new_post/new_post_page.dart";
import "../utils/mock_data/home/mock_posts.dart";

void main() {
  final homePageApp = MaterialApp(
    onGenerateRoute: generateRoute,
    initialRoute: Routes.home.name,
  );

  final emptyMockedPage = ProviderScope(
    child: homePageApp,
  );

  final nonEmptyMockedPage = ProviderScope(
    overrides: [postList.overrideWithValue(testPosts)],
    child: homePageApp,
  );

  testWidgets("new post flow with posts, using bottom bar and come back",
      (tester) async {
    await tester.pumpWidget(nonEmptyMockedPage);
    await tester.pumpAndSettle();

    // Check that the home page is displayed
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

    //Click on the middle element of the bottombar
    final bottomBar = find.byKey(NavigationBottomBar.navigationBottomBarKey);
    await tester.tap(
      find.descendant(
        of: bottomBar,
        matching: find
            .byType(NavigationDestination)
            .at(NavigationbarRoutes.addPost.index),
      ),
    );
    await tester.pumpAndSettle();

    //Check that the new post page is displayed
    final newPostPage = find.byType(NewPostPage);
    expect(newPostPage, findsOneWidget);

    //Go back to the home page
    await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
    await tester.pumpAndSettle();

    //Check that the home page is displayed
    expect(homePage, findsOneWidget);
  });

  testWidgets("new post flow without post, using bottom bar and come back",
      (tester) async {
    await tester.pumpWidget(emptyMockedPage);
    await tester.pumpAndSettle();

    // Check that the home page is displayed
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

    //Click on the middle element of the bottombar
    final bottomBar = find.byKey(NavigationBottomBar.navigationBottomBarKey);
    await tester.tap(
      find.descendant(
        of: bottomBar,
        matching: find
            .byType(NavigationDestination)
            .at(NavigationbarRoutes.addPost.index),
      ),
    );
    await tester.pumpAndSettle();

    //Check that the new post page is displayed
    final newPostPage = find.byType(NewPostPage);
    expect(newPostPage, findsOneWidget);

    //Go back to the home page
    await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
    await tester.pumpAndSettle();

    //Check that the home page is displayed
    expect(homePage, findsOneWidget);
  });

  testWidgets("new post flow without post, using button text and come back",
      (tester) async {
    await tester.pumpWidget(emptyMockedPage);
    await tester.pumpAndSettle();

    // Check that the home page is displayed
    final homePage = find.byType(HomePage);
    expect(homePage, findsOneWidget);

    //Click on the new post button on the home page
    final newPostButtonText = find.byKey(HomeFeed.newPostButtonTextKey);
    await tester.tap(newPostButtonText);
    await tester.pumpAndSettle();

    //Check that the new post page is displayed
    final newPostPage = find.byType(NewPostPage);
    expect(newPostPage, findsOneWidget);

    //Go back to the home page
    await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
    await tester.pumpAndSettle();

    //Check that the home page is displayed
    expect(homePage, findsOneWidget);
  });
}
