import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/users_ranking_view_model.dart";

import "../mocks/data/firestore_user.dart";
import "../mocks/providers/provider_ranking.dart";

void main() {
  group("User ranking view model testing", () {
    late FakeFirebaseFirestore fakeFirestore;
    late ProviderContainer rankingContainer;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await FirestoreUserGenerator.addUsers(
        fakeFirestore,
        UsersRankingViewModel.rankingLimit * 2,
      );

      rankingContainer = rankingProviderContainer(fakeFirestore);
    });

    test("Correct number of users returned", () async {
      final users =
          await rankingContainer.read(usersRankingViewModelProvider.future);

      expect(
        users.rankElementDetailsList.length,
        UsersRankingViewModel.rankingLimit,
      );
    });
  });
}
