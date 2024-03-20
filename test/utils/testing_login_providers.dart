import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_auth_mocks/firebase_auth_mocks.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:google_sign_in_mocks/google_sign_in_mocks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

GoogleSignIn mockGoogleSignIn(ProviderRef<GoogleSignIn> ref) {
  return MockGoogleSignIn();
}

FirebaseAuth mockFirebaseAuth(ProviderRef<FirebaseAuth> ref) {
  final user = MockUser(
    isAnonymous: false,
    uid: "testing_user_id",
    email: "testing.user@gmail.com",
    displayName: "Testing User",
  );

  return MockFirebaseAuth(mockUser: user);
}
