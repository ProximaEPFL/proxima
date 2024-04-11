import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/login/login_page.dart";

import "../services/firebase/setup_firebase_mocks.dart";
import "../services/firebase/testing_auth_providers.dart";
import "../services/test_data/firestore_user_mock.dart";

void main() {
  const delayNeededForAsyncFunctionExecution = Duration(seconds: 1);
  late FakeFirebaseFirestore fakeFireStore;
  late CollectionReference<Map<String, dynamic>> userCollection;
  late UserRepositoryService userRepo;

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  Future<void> enterPseudoAndUsername(WidgetTester tester) async {
    // Enter a valid username and pseudo to make validation work
    final pseudoField = find.byKey(CreateAccountPage.pseudoFieldKey);
    expect(pseudoField, findsOneWidget);
    await tester.enterText(pseudoField, "ANicePseudo");
    await tester.pumpAndSettle();

    final uniqueUsernameField =
        find.byKey(CreateAccountPage.uniqueUsernameFieldKey);
    expect(uniqueUsernameField, findsOneWidget);
    await tester.enterText(uniqueUsernameField, "ANiceUsername");
    await tester.pumpAndSettle();
  }

  group("Existing user data in repository testing", () {
    final expectedUser = testingUserFirestore;

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

    ProviderScope getMockedProxima() {
      return ProviderScope(
        overrides: [
          ...firebaseAuthMocksOverrides,
          userRepositoryProvider.overrideWithValue(userRepo),
        ],
        child: const ProximaApp(),
      );
    }

    testWidgets("Login and get to home page flow", (tester) async {
      await tester.pumpWidget(getMockedProxima());
      await tester.pumpAndSettle();

      final loginButton = find.byKey(LoginButton.loginButtonKey);
      await tester.tap(loginButton);

      //Needs a delay to allow the existance check to complete
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);
    });
  });

  group("Non existing user data in repository testing", () {
    setUp(() async {
      fakeFireStore = FakeFirebaseFirestore();
      userCollection = fakeFireStore.collection(UserFirestore.collectionName);
      userRepo = UserRepositoryService(
        firestore: fakeFireStore,
      );
    });

    ProviderScope getMockedProxima() {
      return ProviderScope(
        overrides: [
          ...firebaseAuthMocksOverrides,
          userRepositoryProvider.overrideWithValue(userRepo),
        ],
        child: const ProximaApp(),
      );
    }

    testWidgets("Login and Logout using create account page", (tester) async {
      await tester.pumpWidget(getMockedProxima());
      await tester.pumpAndSettle();

      final loginButton = find.byKey(LoginButton.loginButtonKey);
      await tester.tap(loginButton);
      //Needs a delay to allow the existance check to complete
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      final createAccountPage = find.byType(CreateAccountPage);
      expect(createAccountPage, findsOneWidget);

      final backButton = find.byKey(LeadingBackButton.leadingBackButtonKey);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      //Check that we are in the login page
      final loginPage = find.byType(LoginPage);
      expect(loginPage, findsOneWidget);
    });

    testWidgets("Login and Logout using home page", (tester) async {
      await tester.pumpWidget(getMockedProxima());
      await tester.pumpAndSettle();

      final loginButton = find.byKey(LoginButton.loginButtonKey);
      await tester.tap(loginButton);
      //Needs a delay to allow the existance check to complete
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      final createAccountPage = find.byType(CreateAccountPage);
      expect(createAccountPage, findsOneWidget);

      await enterPseudoAndUsername(tester);

      final confirmAccountCreating =
          find.byKey(CreateAccountPage.confirmButtonKey);
      await tester.tap(confirmAccountCreating);
      await tester.pumpAndSettle();

      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);

      //Logout and check that we are back to the login page
      final logoutButton = find.byKey(AppTopBar.logoutButtonKey);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      //Check that we are in the login page
      final loginPage = find.byType(LoginPage);
      expect(loginPage, findsOneWidget);
    });

    testWidgets("Login to Create Account Page to Home Page flow",
        (tester) async {
      await tester.pumpWidget(getMockedProxima());
      await tester.pumpAndSettle();

      // Check for the logo on the Login Page
      final logoFinder = find.byKey(LoginPage.logoKey);
      expect(logoFinder, findsOneWidget);

      // Check for the slogan on the Login Page
      final sloganFinder = find.text(LoginPage.tagLineText);
      expect(sloganFinder, findsOneWidget);

      final loginButton = find.byKey(LoginButton.loginButtonKey);
      // Check that the login button is displayed and contains the "Login" text
      expect(
        find.descendant(
          of: loginButton,
          matching: find.text("Sign in with Google"),
        ),
        findsOneWidget,
      );

      await tester.tap(loginButton);
      //Needs a delay to allow the existance check to complete
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      // Check that pressing login redirects to the create account page
      final createAccountPage = find.byType(CreateAccountPage);
      expect(createAccountPage, findsOneWidget);

      await enterPseudoAndUsername(tester);

      // And that pushing the confirm button redirects to the home page
      final confirmButton = find.byKey(CreateAccountPage.confirmButtonKey);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // We must now be on the home page
      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);
    });
  });
}
