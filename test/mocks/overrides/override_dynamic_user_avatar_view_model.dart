import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/viewmodels/dynamic_user_avatar_view_model.dart";

import "../data/firebase_auth_user.dart";

/// A mock implementation of the [DynamicUserAvatarViewModel] class.
class MockDynamicUserAvatarViewModel
    extends AutoDisposeFamilyAsyncNotifier<UserAvatarDetails, UserIdFirestore?>
    implements DynamicUserAvatarViewModel {
  final Future<UserAvatarDetails> Function(UserIdFirestore? arg) _build;

  MockDynamicUserAvatarViewModel({
    Future<UserAvatarDetails> Function(UserIdFirestore? arg)? build,
  }) : _build = build ??
            ((_) async => const UserAvatarDetails(
                  displayName: "",
                  userCentauriPoints: null,
                ));

  @override
  Future<UserAvatarDetails> build(UserIdFirestore? arg) => _build(arg);
}

final mockDynamicUserAvatarViewModelTestLoginUserOverride = [
  dynamicUserAvatarViewModelProvider.overrideWith(
    () => MockDynamicUserAvatarViewModel(
      build: (userUID) async => UserAvatarDetails(
        displayName: testingLoginUser.displayName!,
        userCentauriPoints: ChallengeRepositoryService.soloChallengeReward * 50,
      ),
    ),
  ),
];

final mockDynamicUserAvatarViewModelEmptyDisplayNameOverride = [
  dynamicUserAvatarViewModelProvider.overrideWith(
    () => MockDynamicUserAvatarViewModel(
      build: (userUID) async => const UserAvatarDetails(
        displayName: "",
        userCentauriPoints: null,
      ),
    ),
  ),
];
