import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

import "../data/firestore_user.dart";

/// Returns a testing [ProviderContainer] which purpose is to test the ranking
/// view model.
/// **Note**: it also sets the [testingUserFirestore] on the provided database.
Future<ProviderContainer> rankingProviderContainerWithTestingUser(
  FakeFirebaseFirestore fakeFirebaseFirestore,
) async {
  await setUserFirestore(fakeFirebaseFirestore, testingUserFirestore);

  return ProviderContainer(
    overrides: [
      firestoreProvider.overrideWithValue(fakeFirebaseFirestore),
      validLoggedInUserIdProvider.overrideWithValue(testingUserFirestoreId),
    ],
  );
}
