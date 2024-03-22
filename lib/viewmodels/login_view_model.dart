import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/login_user.dart";
import "package:proxima/services/login_service.dart";

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
