import "package:flutter_test/flutter_test.dart";

import "actions.dart";

void main() {
  testWidgets("Logout from challenges does not cause error", (tester) async {
    await openProxima(tester);

    await loginToCreateAccount(tester);
    await createAccountToHome(tester);

    // Load challenges
    await tester.tap(find.text("Challenge"));
    await tester.pumpAndSettle();

    await toProfilePage(tester);
    await logout(tester);

    await expectNoErrorPopup(tester);
  });
}
