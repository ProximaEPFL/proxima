import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/authentication/auth_login_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/profile/profile_page.dart";
import "../overrides/override_auth_providers.dart";
import "../overrides/override_posts_feed_view_model.dart";

const profilePageApp = MaterialApp(
  onGenerateRoute: generateRoute,
  title: "Profile page",
  home: ProfilePage(),
);

ProviderScope profileProviderScope(
  FakeFirebaseFirestore fakeFireStore,
  Widget child,
) {
  return ProviderScope(
    overrides: [
      ...mockEmptyHomeViewModelOverride,
      firebaseAuthProvider.overrideWith(mockFirebaseAuthSignedIn),
      firestoreProvider.overrideWithValue(fakeFireStore),
    ],
    child: child,
  );
}
