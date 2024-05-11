import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/challenge_details.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";

import "../data/challenge_list.dart";

class MockChallengeViewModel extends AsyncNotifier<List<ChallengeDetails>>
    implements ChallengeViewModel {
  @override
  Future<List<ChallengeDetails>> build() async {
    return mockChallengeList;
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<int?> completeChallenge(PostIdFirestore pid) async {
    return null;
  }
}

final mockChallengeOverride = [
  challengeViewModelProvider.overrideWith(() => MockChallengeViewModel()),
];
