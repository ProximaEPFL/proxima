import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_auth_mocks/firebase_auth_mocks.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:google_sign_in_mocks/google_sign_in_mocks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/login_service.dart";

import "../mock_data/firebase_user_mock.dart";

final firebaseMocksOverrides = [
  firebaseAuthProvider.overrideWith(mockFirebaseAuth),
  googleSignInProvider.overrideWith(mockGoogleSignIn),
];

GoogleSignIn mockGoogleSignIn(ProviderRef<GoogleSignIn> ref) {
  return MockGoogleSignIn();
}

FirebaseAuth mockFirebaseAuth(ProviderRef<FirebaseAuth> ref) {
  return MockFirebaseAuth(mockUser: testingLoginUser);
}
