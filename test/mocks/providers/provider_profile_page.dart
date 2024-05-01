import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/login_service.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/profile/profile_page.dart";

import "../overrides/override_auth_providers.dart";

ProviderScope profilePageProvider(FakeFirebaseFirestore fakeFireStore) {
  final userRepo = UserRepositoryService(
    firestore: fakeFireStore,
  );
  final postRepo = PostRepositoryService(
    firestore: fakeFireStore,
  );

  return ProviderScope(
    overrides: [
      firebaseAuthProvider.overrideWith(mockFirebaseAuthSignedIn),
      userRepositoryProvider.overrideWithValue(userRepo),
      postRepositoryProvider.overrideWithValue(postRepo),
    ],
    child: const MaterialApp(
      onGenerateRoute: generateRoute,
      title: "Profile page",
      home: ProfilePage(),
    ),
  );
}
