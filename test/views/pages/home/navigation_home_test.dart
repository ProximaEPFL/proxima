import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bottom_bar.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/home/content/feed/post_feed.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/new_post/new_post_page.dart";

import "../../../mocks/providers/provider_homepage.dart";

void main() {
  group("Post creation flow", () {
    testWidgets(
        "From non-empty feed, flow to create a post using bottom bar then go back",
        (tester) async {
      await tester.pumpWidget(nonEmptyHomePageProvider);
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
              .at(NavigationBarRoutes.addPost.index),
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

    testWidgets(
        "From empty feed, flow to create a post using bottom bar then go back",
        (tester) async {
      await tester.pumpWidget(emptyHomePageProvider);
      await tester.pumpAndSettle();

      // Check that the home page is displayed
      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);

      //Click on the middle element of the bottombar
      final bottomBar = find.byKey(NavigationBottomBar.navigationBottomBarKey);
      expect(bottomBar, findsOneWidget);
      await tester.tap(
        find.descendant(
          of: bottomBar,
          matching: find
              .byType(NavigationDestination)
              .at(NavigationBarRoutes.addPost.index),
        ),
      );
      await tester.pumpAndSettle();

      //Check that the new post page is displayed
      final newPostPage = find.byType(NewPostPage);
      expect(newPostPage, findsOneWidget);

      //Go back to the home page
      final leadingBackButton =
          find.byKey(LeadingBackButton.leadingBackButtonKey);
      expect(leadingBackButton, findsOneWidget);
      await tester.tap(leadingBackButton);
      await tester.pumpAndSettle();

      //Check that the home page is displayed
      expect(homePage, findsOneWidget);
    });

    testWidgets(
        "From empty feed, flow to create a post, clicking on 'create one!' button then go back",
        (tester) async {
      await tester.pumpWidget(emptyHomePageProvider);
      await tester.pumpAndSettle();

      // Check that the home page is displayed
      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);

      //Click on the new post button on the home page
      final newPostButtonText = find.byKey(PostFeed.newPostButtonTextKey);
      expect(newPostButtonText, findsOneWidget);
      await tester.tap(newPostButtonText);
      await tester.pumpAndSettle();

      //Check that the new post page is displayed
      final newPostPage = find.byType(NewPostPage);
      expect(newPostPage, findsOneWidget);

      //Go back to the home page
      final leadingBackButton =
          find.byKey(LeadingBackButton.leadingBackButtonKey);
      expect(leadingBackButton, findsOneWidget);
      await tester.tap(leadingBackButton);
      await tester.pumpAndSettle();

      //Check that the home page is displayed
      expect(homePage, findsOneWidget);
    });
  });
}
