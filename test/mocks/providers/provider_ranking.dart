import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/pages/home/content/ranking/ranking_page.dart";

import "../data/firestore_user.dart";
import "../services/setup_firebase_mocks.dart";

/// Returns a testing [ProviderContainer] which purpose is to test the ranking
/// view model.
/// **Note**: it also sets the [testingUserFirestore] on the provided database.
Future<ProviderContainer> rankingProviderContainerWithTestingUser(
  FakeFirebaseFirestore fakeFirebaseFirestore,
) async {
  setupFirebaseAuthMocks();
  await Firebase.initializeApp();
  await setUserFirestore(fakeFirebaseFirestore, testingUserFirestore);

  return ProviderContainer(
    overrides: [
      firestoreProvider.overrideWithValue(fakeFirebaseFirestore),
      validLoggedInUserIdProvider.overrideWithValue(testingUserFirestoreId),
    ],
  );
}

/// Returns a testable [RankingPage] already overriden by providers
/// of [rankingProviderContainerWithTestingUser].
Future<UncontrolledProviderScope> rankingPageMockApp(
  FakeFirebaseFirestore fakeFirebaseFirestore,
) async {
  final rankingContainer =
      await rankingProviderContainerWithTestingUser(fakeFirebaseFirestore);

  return UncontrolledProviderScope(
    container: rankingContainer,
    child: const MaterialApp(
      home: RankingPage(),
    ),
  );
}
