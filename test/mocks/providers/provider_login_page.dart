import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/login/login_page.dart";

import "../overrides/override_auth_providers.dart";
import "../overrides/override_home_view_model.dart";

ProviderScope loginPageProvider(FakeFirebaseFirestore fakeFireStore) {
  final userRepo = UserRepositoryService(firestore: fakeFireStore);

  return ProviderScope(
    overrides: [
      ...firebaseAuthMocksOverrides,
      ...mockEmptyHomeViewModelOverride,
      userRepositoryProvider.overrideWithValue(userRepo),
    ],
    child: const MaterialApp(
      onGenerateRoute: generateRoute, // Ensure generateRoute is accessible
      title: "Login page",
      home: LoginPage(), // Ensure LoginPage is imported
    ),
  );
}
