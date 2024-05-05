import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/viewmodels/dynamic_user_avatar_view_model.dart";

import "../data/firebase_auth_user.dart";

/// A mock implementation of the [DynamicUserAvatarViewModel] class.
class MockDynamicUserAvatarViewModel
    extends AutoDisposeFamilyAsyncNotifier<String, UserIdFirestore?>
    implements DynamicUserAvatarViewModel {
  final Future<String> Function(UserIdFirestore? arg) _build;

  MockDynamicUserAvatarViewModel({
    Future<String> Function(UserIdFirestore? arg)? build,
  }) : _build = build ?? ((_) async => "");

  @override
  Future<String> build(UserIdFirestore? arg) => _build(arg);
}

final mockDynamicUserAvatarViewModelTestLoginUserOverride = [
  userDisplayNameProvider.overrideWith(
    () => MockDynamicUserAvatarViewModel(
      build: (userUID) async => testingLoginUser.displayName!,
    ),
  ),
];
