import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../mocks/data/firestore_user.dart";
import "../mocks/providers/provider_ranking.dart";

void main() {
  group("User ranking view model testing", () {
    late FakeFirebaseFirestore fakeFirestore;
    late ProviderContainer rankingContainer;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await FirestoreUserGenerator.addUsers(fakeFirestore, 200);

      rankingContainer = rankingProviderContainer(fakeFirestore);
    });
  });
}
