import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/viewmodels/user_centauri_points_view_model.dart";

import "../mocks/data/firestore_user.dart";

void main() {
  group("User Centauri points ViewModel unit testing", () {
    late FakeFirebaseFirestore fakeFireStore;

    late ProviderContainer container;

    late List<UserFirestore> availableUsers;

    setUp(() async {
      fakeFireStore = FakeFirebaseFirestore();

      availableUsers = FirestoreUserGenerator.generateUserFirestore(10);
      await setUsersFirestore(fakeFireStore, availableUsers);

      //Prepare the list of providers to override.
      container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(fakeFireStore),
        ],
      );
    });

    group("User Centauri points unit testing", () {
      test("Find centauri points given null user id", () async {
        final centauriPoints = await container.read(
          userCentauriPointsViewModelProvider(null).future,
        );
        expect(
          centauriPoints,
          isNull,
        );
      });

      test("Find centauri points given user id in available users", () async {
        for (final user in availableUsers) {
          final centauriPoints = await container.read(
            userCentauriPointsViewModelProvider(user.uid).future,
          );
          expect(
            centauriPoints,
            user.data.centauriPoints,
          );
        }
      });
    });
  });
}
