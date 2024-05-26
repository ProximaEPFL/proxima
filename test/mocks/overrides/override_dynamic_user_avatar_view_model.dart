import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/viewmodels/dynamic_user_avatar_view_model.dart";

import "../data/firebase_auth_user.dart";
import "../data/firestore_user.dart";

/// A mock implementation of the [DynamicUserAvatarViewModel] class.
class MockDynamicUserAvatarViewModel
    extends AutoDisposeFamilyAsyncNotifier<UserAvatarDetails, UserIdFirestore?>
    implements DynamicUserAvatarViewModel {
  final Future<UserAvatarDetails> Function(UserIdFirestore? arg) _build;
  final Future<void> Function() _onRefresh;

  MockDynamicUserAvatarViewModel({
    Future<UserAvatarDetails> Function(UserIdFirestore? arg)? build,
    Future<void> Function()? onRefresh,
  })  : _build = build ??
            ((_) async => const UserAvatarDetails(
                  displayName: "",
                  centauriPoints: null,
                )),
        _onRefresh = onRefresh ?? (() async {});

  @override
  Future<UserAvatarDetails> build(UserIdFirestore? arg) => _build(arg);

  @override
  Future<void> refresh() => _onRefresh();
}

final mockDynamicUserAvatarViewModelTestLoginUserOverride = [
  dynamicUserAvatarViewModelProvider.overrideWith(
    () => MockDynamicUserAvatarViewModel(
      build: (userUID) async => UserAvatarDetails(
        displayName: testingLoginUser.displayName!,
        centauriPoints: testingUserData.centauriPoints,
      ),
    ),
  ),
];

final mockDynamicUserAvatarViewModelEmptyDisplayNameOverride = [
  dynamicUserAvatarViewModelProvider.overrideWith(
    () => MockDynamicUserAvatarViewModel(
      build: (userUID) async => const UserAvatarDetails(
        displayName: "",
        centauriPoints: null,
      ),
    ),
  ),
];
