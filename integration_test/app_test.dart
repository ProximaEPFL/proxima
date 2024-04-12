import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:integration_test/integration_test.dart";
import "package:proxima/main.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/profile/profile_page.dart";

import "../test/services/firebase/setup_firebase_mocks.dart";
import "../test/services/firebase/testing_auth_providers.dart";
import "../test/viewmodels/mock_home_view_model.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFireStore;
  late UserRepositoryService userRepo;

  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    fakeFireStore = FakeFirebaseFirestore();
    userRepo = UserRepositoryService(firestore: fakeFireStore);
  });

  testWidgets("E2E: Login Page -> Create Account -> Home Page",
      (WidgetTester tester) async {
    // Set up the app with mocked providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...firebaseAuthMocksOverrides,
          userRepositoryProvider.overrideWithValue(userRepo),
          postOverviewProvider.overrideWith(
            () => MockHomeViewModel(),
          ),
        ],
        child: const ProximaApp(),
      ),
    );

    await tester.pumpAndSettle();

    /* Login Page */
    final Finder loginButtonFinder = find.byType(LoginButton);
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle(); // Wait for page navigation

    /* Create Account Page */
    expect(find.byType(CreateAccountPage), findsOneWidget);

    // Enter details in the Create Account Page
    await tester.enterText(
        find.byKey(CreateAccountPage.uniqueUsernameFieldKey), "newUsername",);
    await tester.enterText(
        find.byKey(CreateAccountPage.pseudoFieldKey), "newPseudo",);
    await tester.pumpAndSettle();

    // Submit the create account form
    await tester.tap(find.byKey(CreateAccountPage.confirmButtonKey));
    await tester.pumpAndSettle(); // Wait for navigation

    /* Home Page */
    expect(find.byType(HomePage), findsOneWidget);

    /* Profile Page */

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
    final postColumn = find.byKey(ProfilePage.postColumnKey);
    expect(postColumn, findsOneWidget);
    // Tap on the comment tab
    await tester.tap(commentTab);
    await tester.pumpAndSettle();
    // Check that the comment column is displayed
    final commentColumn = find.byKey(ProfilePage.commentColumnKey);
    expect(commentColumn, findsOneWidget);

    // Find arrow back button
    final backButton = find.byType(LeadingBackButton);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);


    /* Challenges */
    await tester.tap(find.text("Challenge"));
    await tester.pumpAndSettle();
    expect(find.text("Challenges"), findsOneWidget);

    /* Group */
    await tester.tap(find.text("Group"));
    await tester.pumpAndSettle();
    expect(find.text("Proxima"), findsOneWidget);

    /* Map */
    await tester.tap(find.text("Map"));
    await tester.pumpAndSettle();
    expect(find.text("Proxima"), findsOneWidget);

  });
}
