import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/views/home_content/challenge/challenge_list.dart";

import "../overrides/override_challenges_view_model.dart";

final mockedChallengeListProvider = ProviderScope(
  overrides: mockChallengeOverride,
  child: const MaterialApp(home: ChallengeList()),
);
