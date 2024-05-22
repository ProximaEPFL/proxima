import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/create_account/create_account_form.dart";
import "package:proxima/views/pages/create_account/create_account_page.dart";
import "package:proxima/views/pages/home/content/feed/post_feed.dart";
import "package:proxima/views/pages/home/content/map/map_screen.dart";
import "package:proxima/views/pages/home/content/map/post_map.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_widget.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/home_top_bar/home_top_bar.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/login/login_page.dart";
import "package:proxima/views/pages/new_post/new_post_form.dart";
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
    await createPost(tester);
    await deletePost(tester);
  });

  testWidgets("Challenge creation and completion", (WidgetTester tester) async {
    // create a post that will be the challenge
    final otherUser = await FirestoreUserGenerator.addUser(fakeFireStore);
    final postLocation = GeoPointGenerator.createOnEdgeInsidePosition(
      startLocation,
      (ChallengeRepositoryService.maxChallengeRadius +
              ChallengeRepositoryService.minChallengeRadius) /
          2,
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

    // complete the challenge
    goToPoint(postLocation);
    await bottomBarNavigate(NavigationbarRoutes.feed, tester);
    final challengePost = find.text(post.data.title);
    expect(challengePost, findsOneWidget);
    await tester.tap(challengePost);
    await tester.pumpAndSettle();

    // check that points are given out
    const reward = ChallengeRepositoryService.soloChallengeReward;
    expect(find.byType(SnackBar), findsOne);
    expect(find.textContaining(reward.toString()), findsOne);

    await tester.tap(find.byKey(LeadingBackButton.leadingBackButtonKey));
    await tester.pumpAndSettle();

    await navigateToProfile(tester);

    final topBar = find.byType(ProfileAppBar);
    final userPoints = find.descendant(
      of: topBar,
      matching: find.textContaining("$reward Centauri"),
    );
    expect(userPoints, findsOne);
  });
}

Future<void> bottomBarNavigate(
  NavigationbarRoutes route,
  WidgetTester tester,
) async {
  final button = find.text(route.name);
  expect(button, findsOneWidget);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> navigateToProfile(WidgetTester tester) async {
  await tester.tap(find.byKey(HomeTopBar.profilePictureKey));
  await tester.pumpAndSettle();
}

Future<void> buttonRefresh(WidgetTester tester) async {
  await tester.tap(find.text("Refresh"));
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
Future<void> createPost(WidgetTester tester) async {
  expect(find.byType(HomePage), findsOneWidget);

  // Tap on the new post button
  await tester.tap(find.byKey(PostFeed.newPostButtonTextKey));
  await tester.pumpAndSettle();

  // Check that the new post page is displayed
  expect(find.byType(NewPostForm), findsOneWidget);

  // Enter post details
  const postTitle = "I like turtles";
  const postDescription = "Look at them go!";

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
}

/// Delete a post
Future<void> deletePost(WidgetTester tester) async {
  expect(find.byType(ProfilePage), findsOneWidget);

  // Check that the post card is displayed
  final postCard = find.byKey(ProfileInfoCard.infoCardKey);
  expect(postCard, findsOneWidget);

  // Check that the post content is displayed
  const postTitle = "I like turtles";
  const postDescription = "Look at them go!";
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
