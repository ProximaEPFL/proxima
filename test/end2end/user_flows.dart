import "package:flutter_test/flutter_test.dart";

import "actions.dart";

void main() {
  testWidgets("End-to-end test of the app navigation flow",
      (WidgetTester tester) async {
    await openProxima(tester);

    await loginToCreateAccount(tester);
    await createAccountToHome(tester);
    await homeToProfilePage(tester);
    await bottomNavigation(tester);
    await createPost(tester);
    await deletePost(tester);
  });
}
