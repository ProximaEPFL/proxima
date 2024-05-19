import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

import "../data/firestore_user.dart";

ProviderContainer rankingProviderContainer(
  FakeFirebaseFirestore fakeFirebaseFirestore,
) {
  setUserFirestore(fakeFirebaseFirestore, testingUserFirestore);

  return ProviderContainer(
    overrides: [
      firestoreProvider.overrideWithValue(fakeFirebaseFirestore),
      validLoggedInUserIdProvider.overrideWith((ref) => testingUserFirestoreId),
    ],
  );
}
