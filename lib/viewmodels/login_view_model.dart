import "package:flutter/widgets.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/login_user.dart";
import "package:proxima/services/login_service.dart";
import "package:proxima/views/navigation/routes.dart";

/// Firebase authentication change provider
final userProvider = StreamProvider<LoginUser?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges().map((user) {
    if (user == null) {
      return null;
    }

    return LoginUser(id: user.uid, email: user.email);
  });
});

/// Firebase authentication change provider to boolean
final isUserLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).valueOrNull != null;
});

/// Login Service provider; dependency injection used for testing purposes
final loginServiceProvider = Provider<LoginService>((ref) {
  return LoginService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

/// Registers the widget to navigate to the login page on logout.
/// This only needs to be called once in the navigation stack,
/// typically in the home page.
void navigateToLoginPageOnLogout(BuildContext context, WidgetRef ref) {
  ref.listen(isUserLoggedInProvider, (_, isLoggedIn) {
    if (!isLoggedIn) {
      // Go to login page when the user is logged out
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login.name,
        (route) => false,
      );
    }
  });
}
