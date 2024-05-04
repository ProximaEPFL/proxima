import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/main.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/views/home_content/feed/post_feed.dart";
import "package:proxima/views/home_content/map/map_screen.dart";
import "package:proxima/views/home_content/map/post_map.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/login/login_page.dart";
import "package:proxima/views/pages/new_post/new_post_form.dart";
import "package:proxima/views/pages/profile/profile_data/profile_user_posts.dart";
import "package:proxima/views/pages/profile/profile_page.dart";

import "../mocks/data/geopoint.dart";
import "../mocks/overrides/override_auth_providers.dart";
import "../mocks/services/mock_geo_location_service.dart";
import "../mocks/services/setup_firebase_mocks.dart";

void main() {
  late FakeFirebaseFirestore fakeFireStore;
  late PostRepositoryService postRepo;
  late UserRepositoryService userRepo;
  late ChallengeRepositoryService challengeRepo;

  MockGeoLocationService geoLocationService = MockGeoLocationService();
  const GeoPoint testLocation = userPosition0;

  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    fakeFireStore = FakeFirebaseFirestore();
    postRepo = PostRepositoryService(firestore: fakeFireStore);
    userRepo = UserRepositoryService(
      firestore: fakeFireStore,
    );
    challengeRepo = ChallengeRepositoryService(
      firestore: fakeFireStore,
      postRepositoryService: postRepo,
      userRepositoryService: userRepo,
    );
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(testLocation),
    );
    when(geoLocationService.getPositionStream()).thenAnswer(
      (_) => Stream.value(testLocation),
    );
  });

  testWidgets("End-to-end test of the app navigation flow",
      (WidgetTester tester) async {
    // Set up the app with mocked providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...firebaseAuthMocksOverrides,
          userRepositoryProvider.overrideWithValue(userRepo),
          geoLocationServiceProvider.overrideWithValue(geoLocationService),
          postRepositoryProvider.overrideWithValue(postRepo),
          challengeRepositoryServiceProvider.overrideWithValue(challengeRepo),
        ],
        child: const ProximaApp(),
      ),
    );

    await tester.pumpAndSettle();

    await loginToCreateAccount(tester);
    await createAccountToHome(tester);
    await homeToProfilePage(tester);
    await bottomNavigation(tester);
    await createPost(tester);
  });
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
    find.byKey(CreateAccountPage.uniqueUsernameFieldKey),
    "newUsername",
  );
  await tester.enterText(
    find.byKey(CreateAccountPage.pseudoFieldKey),
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

  final profilePicture = find.byKey(AppTopBar.profilePictureKey);
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

  // Group
  await tester.tap(find.text("Group"));
  await tester.pumpAndSettle();
  expect(find.text("Proxima"), findsOneWidget);

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
  final profilePicture = find.byKey(AppTopBar.profilePictureKey);
  await tester.tap(profilePicture);
  await tester.pumpAndSettle();
  expect(find.text(postTitle), findsOneWidget);
  expect(find.text(postDescription), findsOneWidget);
}
