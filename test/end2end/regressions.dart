import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";
import "package:proxima/views/pages/profile/components/logout_button.dart";

import "actions.dart";

void main() {
  testWidgets("Logout from challenges does not cause error", (tester) async {
    await openProxima(tester);

    await loginToCreateAccount(tester);
    await createAccountToHome(tester);

    // Load challenges
    await tester.tap(find.text("Challenge"));
    await tester.pumpAndSettle();

    // Go to profile page
    final profilePicture = find.byKey(AppTopBar.profilePictureKey);
    expect(profilePicture, findsOneWidget);
    await tester.tap(profilePicture);
    await tester.pumpAndSettle();

    final logoutButton = find.byKey(LogoutButton.logoutButtonKey);
    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    final errorPopup = find.bySubtype<AlertDialog>();
    expect(errorPopup, findsNothing);
  });
}
