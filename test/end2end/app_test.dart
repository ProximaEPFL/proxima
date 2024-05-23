import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/create_account/create_account_form.dart";
import "package:proxima/views/pages/create_account/create_account_page.dart";
import "package:proxima/views/pages/home/content/challenge/challenge_list.dart";
import "package:proxima/views/pages/home/content/feed/components/post_card.dart";
import "package:proxima/views/pages/home/content/feed/post_feed.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";
import "package:proxima/views/pages/home/content/map/post_map.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_widget.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/home_top_bar/home_top_bar.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/login/login_page.dart";
import "package:proxima/views/pages/new_post/new_post_form.dart";
import "package:proxima/views/pages/post/components/new_comment/new_comment_button.dart";
import "package:proxima/views/pages/post/components/new_comment/new_comment_textfield.dart";
import "package:proxima/views/pages/profile/components/info_cards/profile_info_card.dart";
import "package:proxima/views/pages/profile/components/profile_app_bar.dart";
import "package:proxima/views/pages/profile/components/profile_data/profile_user_posts.dart";
import "package:proxima/views/pages/profile/profile_page.dart";
import "package:proxima/views/proxima_app.dart";

import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/overrides/override_auth_providers.dart";
import "../mocks/services/mock_geo_location_service.dart";
import "../mocks/services/setup_firebase_mocks.dart";
import "../utils/delay_async_func.dart";

void main() {
  const testPostTitle = "I like turtles";
  const testPostDescription = "Look at them go!";

  late FakeFirebaseFirestore fakeFireStore;

  MockGeolocationService geoLocationService = MockGeolocationService();
  const GeoPoint startLocation = userPosition1;

  setUp(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    fakeFireStore = FakeFirebaseFirestore();

    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(startLocation),
    );
    when(geoLocationService.getPositionStream()).thenAnswer(
      (_) => Stream.value(startLocation),
    );
  });

  /// Pump the full Proxima app into the tester.
  Future<void> loadProxima(WidgetTester tester) async {
    // Set up the app with mocked providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...firebaseAuthMocksOverrides,
          geolocationServiceProvider.overrideWithValue(geoLocationService),
          firestoreProvider.overrideWithValue(fakeFireStore),
        ],
        child: const ProximaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  void goToPoint(GeoPoint point) {
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(point),
    );
    when(geoLocationService.getPositionStream()).thenAnswer(
      (_) => Stream.value(point),
    );
  }

  testWidgets("End-to-end test of the app navigation flow",
      (WidgetTester tester) async {
    await loadProxima(tester);

    await loginToCreateAccount(tester);
    await createAccountToHome(tester);
    await homeToProfilePage(tester);
    await bottomNavigation(tester);
    await createPost(tester, testPostTitle, testPostDescription);
    await deletePost(tester, testPostTitle, testPostDescription);
  });

  testWidgets("Challenge creation and completion", (WidgetTester tester) async {
    // create a post that will be the challenge
    final otherUser = await FirestoreUserGenerator.addUser(fakeFireStore);
    final postLocation = GeoPointGenerator.createOnEdgeInsidePosition(
      startLocation,
      ChallengeRepositoryService.maxChallengeRadius,
    );
    final post =
        FirestorePostGenerator().createUserPost(otherUser.uid, postLocation);
    await setPostFirestore(post, fakeFireStore);

    await loadProxima(tester);
    await loginToCreateAccount(tester);
    await createAccountToHome(tester);

    // get the challenge
    await bottomBarNavigate(NavigationbarRoutes.challenge, tester);
    expect(find.text(post.data.title), findsOneWidget);

    // complete the challenge with intermediate positions
    List<GeoPoint> intermediatePositions =
        GeoPointGenerator.linearInterpolation(startLocation, postLocation, 10);
    for (final point in intermediatePositions) {
      goToPoint(point);
      await flingRefresh(tester, find.byType(ChallengeList));

      final challengeDescription = find.textContaining(
        "meters",
        findRichText: true,
      );
      expect(challengeDescription, findsOne);

      final challengeDescriptionWidget =
          challengeDescription.evaluate().first.widget as RichText;
      final challengeDescriptionText =
          challengeDescriptionWidget.text.toPlainText();

      // use regex to extract <number> meters
      final actualDist = int.parse(
        RegExp(r"(\d+) meters").firstMatch(challengeDescriptionText)!.group(1)!,
      );

      final int expectedDist =
          (GeoFirePoint(point).distanceBetweenInKm(geopoint: postLocation) *
                  1000)
              .toInt();

      expect(actualDist, expectedDist);
    }

    await bottomBarNavigate(NavigationbarRoutes.feed, tester);
    await openPost(tester, post.data.title);

    // check that points are given out
    const reward = ChallengeRepositoryService.soloChallengeReward;
    expect(find.byType(SnackBar), findsOne);
    expect(find.textContaining(reward.toString()), findsOne);

    await navigateBack(tester);
    await navigateToProfile(tester);

    final topBar = find.byType(ProfileAppBar);
    final userPoints = find.descendant(
      of: topBar,
      matching: find.textContaining("$reward Centauri"),
    );
    expect(userPoints, findsOne);
  });

  testWidgets("Commenting on my post", (WidgetTester tester) async {
    await loadProxima(tester);
    await loginToCreateAccount(tester);
    await createAccountToHome(tester);
    await createPost(tester, testPostTitle, testPostDescription);
    await openPost(tester, testPostTitle);
    const comment = "I like turtles too!";
    await addComment(tester, comment);

    // back to feed
    await navigateBack(tester);
    await flingRefresh(tester, find.byType(PostFeed));

    // expect comment count to be correct
    expectCommentCount(tester, testPostTitle, 1);
    await deleteComment(tester, comment);
    expectCommentCount(tester, testPostTitle, 0);
  });
}

/// Expect the comment count of a post to be [count], starts in the home feed.
Future<void> expectCommentCount(
  WidgetTester tester,
  String postTitle,
  int count,
) async {
  // find the post card that contains the correct title
  final postCard = find.ancestor(
    of: find.text(postTitle),
    matching: find.byKey(PostCard.postCardKey),
  );

  final commentsCount = find.descendant(
    of: postCard,
    matching: find.byKey(PostCard.postCardCommentsNumberKey),
  );
  expect(commentsCount, findsOne);
  final commentCountText = find.descendant(
    of: commentsCount,
    matching: find.textContaining("$count"),
  );
  expect(commentCountText, findsOne);
}

/// Write a comment with content [comment] and post it. Starts in the post page.
Future<void> addComment(WidgetTester tester, String comment) async {
  final commentField = find.byKey(NewCommentTextField.addCommentTextFieldKey);
  await tester.enterText(commentField, comment);
  await tester.tap(find.byKey(NewCommentButton.postCommentButtonKey));
  await tester.pumpAndSettle();

  expect(find.text(comment), findsOne);
}

/// Open a post by tapping on its title, starting from the home feed
Future<void> openPost(WidgetTester tester, String postTitle) async {
  await tester.tap(find.text(postTitle));
  await tester.pumpAndSettle();
}

/// Navigate back using the back button in the app bar
Future<void> navigateBack(WidgetTester tester) async {
  await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
  await tester.pumpAndSettle();
}

/// Navigate use the bottom navigation bar to open [route]. Starts from any
/// page with a bottom navigation bar.
Future<void> bottomBarNavigate(
  NavigationbarRoutes route,
  WidgetTester tester,
) async {
  final button = find.text(route.name);
  expect(button, findsOneWidget);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// Navigate to the profile page. Starts from any page with a profile button.
Future<void> navigateToProfile(WidgetTester tester) async {
  await tester.tap(find.byKey(HomeTopBar.profilePictureKey));
  await tester.pumpAndSettle();
}

/// Refresh the page by tapping the refresh button. Starts from any page with a
/// refresh button.
Future<void> buttonRefresh(WidgetTester tester) async {
  await tester.tap(find.text("Refresh"));
  await tester.pumpAndSettle();
}

/// Refreshes the page by flinging down the widget [finder].
Future<void> flingRefresh(
  WidgetTester tester,
  FinderBase<Element> finder,
) async {
  await tester.fling(finder, const Offset(0, 400), 800);
  await tester.pumpAndSettle();
}

/// Navigate to the login page and login
Future<void> loginToCreateAccount(WidgetTester tester) async {
  expect(find.byType(LoginPage), findsOneWidget);

  final loginButton = find.byKey(LoginButton.loginButtonKey);
  await tester.tap(loginButton);
  await tester.pumpAndSettle();
}

/// Create an account and navigate to the home page
Future<void> createAccountToHome(WidgetTester tester) async {
  expect(find.byType(CreateAccountPage), findsOneWidget);

  // Enter details in the Create Account Page
  await tester.enterText(
    find.byKey(CreateAccountForm.uniqueUsernameFieldKey),
    "newUsername",
  );
  await tester.enterText(
    find.byKey(CreateAccountForm.pseudoFieldKey),
    "newPseudo",
  );
  await tester.pumpAndSettle();

  // Submit the create account form
  await tester.tap(find.byKey(CreateAccountPage.confirmButtonKey));
  await tester.pumpAndSettle(); // Wait for navigation

  expect(find.byType(HomePage), findsOneWidget);
}

/// Navigate to profile page from home page and go back
Future<void> homeToProfilePage(WidgetTester tester) async {
  expect(find.byType(HomePage), findsOneWidget);

  final profilePicture = find.byKey(HomeTopBar.profilePictureKey);
  expect(profilePicture, findsOneWidget);
  await tester.tap(profilePicture);
  await tester.pumpAndSettle();

  // Check that the profile page is displayed
  final profilePage = find.byType(ProfilePage);
  expect(profilePage, findsOneWidget);

  // Check that the post tab is displayed
  final postTab = find.byKey(ProfilePage.postTabKey);
  expect(postTab, findsOneWidget);

  // Check that the comment tab is displayed
  final commentTab = find.byKey(ProfilePage.commentTabKey);
  expect(commentTab, findsOneWidget);

  //Check that post column is displayed
  final postColumn = find.byKey(ProfileUserPosts.postColumnKey);
  expect(postColumn, findsOneWidget);

  // Tap on the comment tab
  await tester.tap(commentTab);
  await tester.pumpAndSettle();

  // Check that the comment column is displayed
  final commentColumn = find.byKey(ProfilePage.commentColumnKey);
  expect(commentColumn, findsOneWidget);

  // Find arrow back button and go back to home page
  final backButton = find.byType(LeadingBackButton);
  expect(backButton, findsOneWidget);
  await tester.tap(backButton);
  await tester.pumpAndSettle();
  expect(find.byType(HomePage), findsOneWidget);
}

/// Navigate to the other pages using bottom navigation bar
Future<void> bottomNavigation(WidgetTester tester) async {
  expect(find.byType(HomePage), findsOneWidget);

  // Challenges
  await tester.tap(find.text("Challenge"));
  await tester.pumpAndSettle();
  expect(find.text("Challenges"), findsOneWidget);

  // Ranking
  await tester.tap(find.text("Ranking"));
  await tester.pumpAndSettle();
  expect(find.byType(RankingWidget), findsOneWidget);

  // Map
  await tester.tap(find.text("Map"));
  await tester.pumpAndSettle();
  expect(find.byType(MapScreen), findsOneWidget);
  expect(find.byType(PostMap), findsOneWidget);

  // New Post
  await tester.tap(find.text("New post"));
  await tester.pumpAndSettle();
  expect(find.text("Create a new post"), findsOneWidget);
  await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
  await tester.pumpAndSettle();

  // Home (Feed)
  await tester.tap(find.text("Feed"));
  await tester.pumpAndSettle();
  expect(find.byType(HomePage), findsOneWidget);
}

/// Create a post
/// starts from home feed and ends in home feed
Future<void> createPost(
  WidgetTester tester,
  String postTitle,
  String postDescription,
) async {
  expect(find.byType(HomePage), findsOneWidget);

  // Tap on the new post button
  await tester.tap(find.byKey(PostFeed.newPostButtonTextKey));
  await tester.pumpAndSettle();

  // Check that the new post page is displayed
  expect(find.byType(NewPostForm), findsOneWidget);

  await tester.enterText(
    find.byKey(NewPostForm.titleFieldKey),
    postTitle,
  );

  await tester.enterText(
    find.byKey(NewPostForm.bodyFieldKey),
    postDescription,
  );

  await tester.pumpAndSettle();

  // Submit the post
  await tester.tap(find.byKey(NewPostForm.postButtonKey));
  await tester.pumpAndSettle();

  // refresh the page by pulling down
  await tester.drag(find.byType(PostFeed), const Offset(0, 500));
  await tester.pumpAndSettle();

  // Check that the post is displayed in feed
  expect(find.text(postTitle), findsOneWidget);
  expect(find.text(postDescription), findsOneWidget);

  // Check that the post is displayed in profile page
  final profilePicture = find.byKey(HomeTopBar.profilePictureKey);
  await tester.tap(profilePicture);
  await tester.pumpAndSettle();
  expect(find.text(postTitle), findsOneWidget);
  expect(find.text(postDescription), findsOneWidget);
  final postCard = find.byKey(ProfileInfoCard.infoCardKey);
  expect(postCard, findsOneWidget);

  await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
  await tester.pumpAndSettle();
}

/// Delete a post
/// starts from home feed
Future<void> deletePost(
  WidgetTester tester,
  String postTitle,
  String postDescription,
) async {
  await navigateToProfile(tester);

  expect(find.byType(ProfilePage), findsOneWidget);

  // Check that the post card is displayed
  final postCard = find.byKey(ProfileInfoCard.infoCardKey);
  expect(postCard, findsOneWidget);

  // Check that the post content is displayed
  expect(find.text(postTitle), findsOneWidget);
  expect(find.text(postDescription), findsOneWidget);

  // Find the delete button on card
  final deleteButton = find.byKey(ProfileInfoCard.deleteButtonCardKey);
  expect(deleteButton, findsOneWidget);

  await tester.tap(deleteButton);
  await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

  // Can't find post anymore
  expect(find.text(postTitle), findsNothing);
  expect(find.text(postDescription), findsNothing);

  // Check that the post card is not displayed anymore
  expect(postCard, findsNothing);

  // Go back to home page
  final backButton = find.byType(LeadingBackButton);
  expect(backButton, findsOneWidget);
  await tester.tap(backButton);
  await tester.pumpAndSettle();
  expect(find.byType(HomePage), findsOneWidget);

  // Can't find post anymore
  expect(find.text(postTitle), findsNothing);
  expect(find.text(postDescription), findsNothing);
}

/// Delete a comment
/// starts from home feed
Future<void> deleteComment(
  WidgetTester tester,
  String comment,
) async {
  await navigateToProfile(tester);

  expect(find.byType(ProfilePage), findsOneWidget);

  await tester.tap(find.byKey(ProfilePage.commentTabKey));
  await tester.pumpAndSettle();

  // Check that the post content is displayed
  expect(find.text(comment), findsOneWidget);

  // Find the delete button on card
  final deleteButton = find.byKey(ProfileInfoCard.deleteButtonCardKey);
  expect(deleteButton, findsOneWidget);

  await tester.tap(deleteButton);
  await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

  // Can't find post anymore
  expect(find.text(comment), findsNothing);

  await navigateBack(tester);
}
