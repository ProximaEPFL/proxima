import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/models/ui/challenge_card_data.dart";
import "package:proxima/viewmodels/challenge_view_model.dart";

import "../data/challenge_list.dart";

class MockChallengeViewModel extends AsyncNotifier<List<ChallengeCardData>>
    implements ChallengeViewModel {
  @override
  Future<List<ChallengeCardData>> build() async {
    return mockChallengeList;
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<bool> completeChallenge(PostIdFirestore pid) async {
    return false;
  }
}

final mockChallengeOverride = [
  challengeProvider.overrideWith(() => MockChallengeViewModel()),
];
