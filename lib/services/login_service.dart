import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

/// Login service
class LoginService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  LoginService({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  Future<void> signIn() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    //Check that the auth details are valid
    if (googleAuth?.accessToken != null || googleAuth?.idToken != null) {
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await _firebaseAuth.signInWithCredential(credential);
    } else if (googleUser != null) {
      // Failed to sign in with Firebase
      await _googleSignIn.signOut();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}

/// Static singleton [GoogleSignIn] instance provider
final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn(),
);

/// Static singleton [FirebaseAuth] instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
