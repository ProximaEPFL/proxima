import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/pages/create_account_page.dart";
import "package:proxima/views/pages/home/home_page.dart";

import "../../mocks/providers/provider_create_account.dart";

void main() {
  Future<(Finder, Finder, Finder)> preparePage(WidgetTester tester) async {
    await tester.pumpWidget(createAccountPageProvider);
    await tester.pumpAndSettle();

    final uniqueUsernameField =
        find.byKey(CreateAccountPage.uniqueUsernameFieldKey);
    expect(uniqueUsernameField, findsOneWidget);
    await tester.enterText(uniqueUsernameField, "AUniqueUsername");

    final pseudoField = find.byKey(CreateAccountPage.pseudoFieldKey);
    expect(pseudoField, findsOneWidget);
    await tester.enterText(pseudoField, "ANicePseudo");

    final confirmButton = find.byKey(CreateAccountPage.confirmButtonKey);
    expect(confirmButton, findsOneWidget);

    await tester.pumpAndSettle();

    return (uniqueUsernameField, pseudoField, confirmButton);
  }

  group("Widgets display", () {
    testWidgets("Display text fields and buttons", (tester) async {
      final (uniqueUsernameField, pseudoField, confirmButton) =
          await preparePage(tester);

      expect(uniqueUsernameField, findsOneWidget);
      expect(pseudoField, findsOneWidget);
      expect(confirmButton, findsOneWidget);
    });
  });

  group("Invalid username and pseudos should produce an error", () {
    const blank = "blank";
    const space = "space";
    const short = "short";
    const long = "long";
    const specialCharacter = "Invalid characters";

    final incorrectStrings = [
      ("", blank),
      (" ", space),
      ("he llo", space),
      ("heLlo ", space),
      ("A", short),
      ("a%", short),
      ("0" * 21, long),
      ("j" * 512, long),
      (
        "jdsfklsdjflkdsjlfkjwioeoiwelkfmscvhklwjefkhjwiejfknsdkjfsdklfmjksdjfwmkfn",
        long
      ),
      ("abc&", specialCharacter),
      ("_é_Jsdljadlkfjsd", specialCharacter),
      ("🐘🐋🐘", specialCharacter),
    ];

    for (final field in ["username", "pseudo"]) {
      for (final (value, error) in incorrectStrings) {
        testWidgets(
            "Invalid $field error should contain '$error' on value '$value'",
            (tester) async {
          final (uniqueUsernameField, pseudoField, confirmButton) =
              await preparePage(tester);

          final errorText = find.textContaining(error);
          expect(errorText, findsNothing);

          final fieldFinder =
              field == "username" ? uniqueUsernameField : pseudoField;
          await tester.enterText(fieldFinder, value);
          await tester.pumpAndSettle();

          await tester.tap(confirmButton);
          await tester.pumpAndSettle();

          expect(errorText, findsOneWidget);
        });
      }
    }
  });

  final correctStrings = [
    "ElePhaNTS",
    "a" * 3,
    "A" * 20,
    "XxX_SoBg_XxX",
    "___",
  ];

  group("Valid username and pseudos should not produce an error", () {
    for (final value in correctStrings) {
      testWidgets(
          "Username and pseudo both with value $value should not produce an error",
          (tester) async {
        final (uniqueUsernameField, pseudoField, confirmButton) =
            await preparePage(tester);

        // Remark: Both fields are set to the same value since the
        // database is not reset between tests. This means that if
        // we change the pseudo but not the username, we have an error
        // for a non-unique username.
        await tester.enterText(uniqueUsernameField, value);
        await tester.enterText(pseudoField, value);
        await tester.pumpAndSettle();

        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        final homePage = find.byType(HomePage);
        expect(homePage, findsOneWidget);
      });
    }
  });

  testWidgets("Two users cannot log in with the same username", (tester) async {
    const username = "evryoneloveelephants";
    final errorText = find.textContaining("already taken");

    // User 1 attempts to register
    {
      final (uniqueUsernameField, pseudoField, confirmButton) =
          await preparePage(tester);

      await tester.enterText(uniqueUsernameField, username);
      await tester.enterText(pseudoField, "pseudo0");
      await tester.pumpAndSettle();

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(errorText, findsNothing);
      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);
    }
    // a bit hacky, but it appears to be necessary to reset the home page
    // I have tried many other things, this one appears to be
    // the one that makes the most sense amongst the ones that worked
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // User 2 attempts to register with the same username
    {
      final (uniqueUsernameField, pseudoField, confirmButton) =
          await preparePage(tester);

      await tester.enterText(uniqueUsernameField, username);
      await tester.enterText(pseudoField, "pseudo1");
      await tester.pumpAndSettle();

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(errorText, findsOneWidget);
    }
  });
}
