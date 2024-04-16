import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/login_service.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_badge.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_post.dart";
import "package:proxima/views/pages/profile/posts_info/info_row.dart";
import "package:proxima/views/pages/profile/profile_page.dart";
import "package:proxima/views/pages/profile/user_info/user_account.dart";
import "../services/firebase/setup_firebase_mocks.dart";
import "../services/firebase/testing_auth_providers.dart";
import "../services/test_data/firestore_user_mock.dart";
import "../viewmodels/mock_home_view_model.dart";

void main() {
  late FakeFirebaseFirestore fakeFireStore;
  late CollectionReference<Map<String, dynamic>> userCollection;
  late UserRepositoryService userRepo;

  final expectedUser = testingUserFirestore;
  setupFirebaseAuthMocks();

  setUp(() async {
    fakeFireStore = FakeFirebaseFirestore();
    userCollection = fakeFireStore.collection(UserFirestore.collectionName);
    userRepo = UserRepositoryService(
      firestore: fakeFireStore,
    );
    await userCollection
        .doc(expectedUser.uid.value)
        .set(expectedUser.data.toDbData());
  });
  testWidgets("Navigate to profile page", (tester) async {
    final homePageWidget = ProviderScope(
      overrides: [
        postOverviewProvider.overrideWith(
          () => MockHomeViewModel(),
        ),
      ],
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        title: "Proxima",
        home: HomePage(),
      ),
    );

    await tester.pumpWidget(homePageWidget);
    await tester.pumpAndSettle();

    // Check that the top bar is displayed
    final topBar = find.byKey(AppTopBar.homeTopBarKey);
    expect(topBar, findsOneWidget);

    //Check profile picture is displayed
    final profilePicture = find.byKey(AppTopBar.profilePictureKey);
    expect(profilePicture, findsOneWidget);

    // Tap on the profile picture
    await tester.tap(profilePicture);
    await tester.pumpAndSettle();

    // Check that the profile page is displayed
    final profilePage = find.byType(ProfilePage);
    expect(profilePage, findsOneWidget);
  });

  testWidgets("Various widget are displayed", (tester) async {
    setupFirebaseAuthMocks();

    Widget profilePageWidget = ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWith(mockFirebaseAuthSignedIn),
        userRepositoryProvider.overrideWithValue(userRepo),
      ],
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        title: "Profile page",
        home: ProfilePage(),
      ),
    );

    await tester.pumpWidget(profilePageWidget);
    await tester.pumpAndSettle();

    // Check that badges are displayed
    final badgeCard = find.byKey(InfoCardBadge.infoCardBadgeKey);
    expect(badgeCard, findsWidgets);

    //Check that the post card is displayed
    final postCard = find.byKey(InfoCardPost.infoCardPostKey);
    expect(postCard, findsWidgets);

    // Check that the info column is displayed
    final infoColumn = find.byKey(ProfilePage.postColumnKey);
    expect(infoColumn, findsOneWidget);

    // Check that the info row is displayed
    final infoRowWidget = find.byKey(InfoRow.infoRowKey);
    expect(infoRowWidget, findsOneWidget);

    //Check that centauri points are displayed
    final centauriPoints = find.byKey(UserAccount.centauriPointsKey);
    expect(centauriPoints, findsOneWidget);

    //Check that the user account is displayed
    final userAccount = find.byKey(UserAccount.userInfoKey);
    expect(userAccount, findsOneWidget);

    //Check that the tab is displayed
    final tab = find.byKey(ProfilePage.tabKey);
    expect(tab, findsOneWidget);
  });

  testWidgets("Tab working as expected", (tester) async {
    setupFirebaseAuthMocks();

    Widget profilePageWidget = ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWith(mockFirebaseAuthSignedIn),
        userRepositoryProvider.overrideWithValue(userRepo),
      ],
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        title: "Profile page",
        home: ProfilePage(),
      ),
    );

    await tester.pumpWidget(profilePageWidget);
    await tester.pumpAndSettle();

    // Check that the post tab is displayed
    final postTab = find.byKey(ProfilePage.postTabKey);
    expect(postTab, findsOneWidget);

    // Check that the comment tab is displayed
    final commentTab = find.byKey(ProfilePage.commentTabKey);
    expect(commentTab, findsOneWidget);

    //Check that post column is displayed
    final postColumn = find.byKey(ProfilePage.postColumnKey);
    expect(postColumn, findsOneWidget);

    // Tap on the comment tab
    await tester.tap(commentTab);
    await tester.pumpAndSettle();

    // Check that the comment column is displayed
    final commentColumn = find.byKey(ProfilePage.commentColumnKey);
    expect(commentColumn, findsOneWidget);
  });

  testWidgets("Centauri points incrementing correctly", (tester) async {
    setupFirebaseAuthMocks();

    Widget profilePageWidget = ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWith(mockFirebaseAuthSignedIn),
        userRepositoryProvider.overrideWithValue(userRepo),
      ],
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        title: "Profile page",
        home: ProfilePage(),
      ),
    );

    await tester.pumpWidget(profilePageWidget);
    await tester.pumpAndSettle();

    //Check that centauri points are displayed
    final centauriPoints = find.byKey(UserAccount.centauriPointsKey);
    expect(centauriPoints, findsOneWidget);

    // checking the text
    final centauriText = find.text("username_8456 · 0 Centauri");
    expect(centauriText, findsOneWidget);

    //TODO: remove this test when the setting button is implemented
    final settingsButton = find.byKey(ProfilePage.settingsKey);
    expect(settingsButton, findsOneWidget);

    // Tap on the settings button
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    //Check that the centauri points are incremented
    final centauriPointsIncremented = find.text("username_8456 · 5 Centauri");
    expect(centauriPointsIncremented, findsOneWidget);
  });
}
