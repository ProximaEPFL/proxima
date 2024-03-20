import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/main.dart";
import "package:proxima/services/login_service.dart";

import "testing_login_providers.dart";

/// Utility testing class used to wrap a widget with the appropriate testing provider scope
class TestingProviderScope extends StatelessWidget {
  final Widget child;

  const TestingProviderScope({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // dependency injected mocks using providers
      overrides: [
        firebaseAuthProvider.overrideWith(mockFirebaseAuth),
        googleSignInProvider.overrideWith(mockGoogleSignIn),
      ],
      child: child,
    );
  }
}

/// Utility method to properly instantiate a `wut` (widget under test)
Widget testingWidget(Widget wut) {
  return TestingProviderScope(child: wut);
}

/// Utility method to properly instantiate a test version of the entire application
Widget testingApp() {
  return testingWidget(const ProximaApp());
}
