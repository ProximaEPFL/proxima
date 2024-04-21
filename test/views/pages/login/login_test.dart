import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";
import "package:proxima/views/pages/login/login_button.dart";
import "package:proxima/views/pages/login/login_page.dart";

import "../../../mocks/data/mock_firestore_user.dart";
import "../../../mocks/mock_home_view_model.dart";
import "../../../mocks/setup_firebase_mocks.dart";
import "../../../services/firebase/testing_auth_providers.dart";

void main() {
  const delayNeededForAsyncFunctionExecution = Duration(seconds: 1);
  late FakeFirebaseFirestore fakeFireStore;
  late CollectionReference<Map<String, dynamic>> userCollection;
  late UserRepositoryService userRepo;
  late ProviderScope mockedLoginPage;

  setUp(() async {
    setupFirebaseAuthMocks();
    fakeFireStore = FakeFirebaseFirestore();
    userCollection = fakeFireStore.collection(UserFirestore.collectionName);
    userRepo = UserRepositoryService(
      firestore: fakeFireStore,
    );
    mockedLoginPage = ProviderScope(
      overrides: [
            ...firebaseAuthMocksOverrides,
            userRepositoryProvider.overrideWithValue(userRepo),
          ] +
          mockEmptyHomeViewModelOverride,
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        home: LoginPage(),
      ),
    );
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

  group("Widgets display", () {
    testWidgets("Display logo, slogan and login button", (tester) async {
      await tester.pumpWidget(mockedLoginPage);
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
    });
  });

  group("Existing user data in repository testing", () {
    final expectedUser = testingUserFirestore;

    // override the setup to add a user
    setUp(() async {
      // Add a user to the collection
      await userCollection
          .doc(expectedUser.uid.value)
          .set(expectedUser.data.toDbData());
    });

    testWidgets("Login flow to HomePage", (tester) async {
      await tester.pumpWidget(mockedLoginPage);
      await tester.pumpAndSettle();

      final loginButton = find.byKey(LoginButton.loginButtonKey);
      await tester.tap(loginButton);

      //Needs a delay to allow the existence check to complete
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);
    });
  });

  group("Non existing user data in repository testing", () {
    testWidgets("Login flow to CreateAccount and log out", (tester) async {
      await tester.pumpWidget(mockedLoginPage);
      await tester.pumpAndSettle();

      final loginButton = find.byKey(LoginButton.loginButtonKey);
      await tester.tap(loginButton);
      //Needs a delay to allow the existence check to complete
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

    testWidgets("Login flow to HomePage and log out", (tester) async {
      await tester.pumpWidget(mockedLoginPage);
      await tester.pumpAndSettle();

      final loginButton = find.byKey(LoginButton.loginButtonKey);
      await tester.tap(loginButton);
      //Needs a delay to allow the existence check to complete
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
  });
}
