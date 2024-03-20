import "package:firebase_auth/firebase_auth.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:proxima/models/login_user.dart";
import "package:proxima/services/implementations/login_service_firebase.dart";
import "package:proxima/services/login_service.dart";

class LoginViewModel extends Notifier<LoginUser?> {
  final LoginService loginService;

  LoginViewModel(this.loginService);

  @override
  LoginUser? build() {
    return ref.watch(authProvider).value;
  }

  void signInRequest() {
    loginService.signIn();
  }

  void signOut() {
    loginService.signOut();
  }
}

// Firebase authentication change provider
final authProvider = StreamProvider<LoginUser?>((ref) {
  return FirebaseAuth.instance
      .authStateChanges()
      .where((user) => user != null)
      .map((user) => LoginUser(id: user!.uid, email: user.email));
});

// User viwemodel provider
final userProvider = NotifierProvider<LoginViewModel, LoginUser?>(() {
  return LoginViewModel(LoginServiceFirebase());
});
