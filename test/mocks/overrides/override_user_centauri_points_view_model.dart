import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/viewmodels/user_centauri_points_view_model.dart";

/// A mock implementation of the [UserCentauriPointsViewModel] class.
class MockUserAvatarCentauriPointsViewModel
    extends FamilyAsyncNotifier<int?, UserIdFirestore?>
    implements UserCentauriPointsViewModel {
  final Future<int?> Function(UserIdFirestore? arg) _build;
  final Future<void> Function() _onRefresh;
  final Future<void> Function() _onRefreshWithCentauriPointsNumber;

  MockUserAvatarCentauriPointsViewModel({
    Future<int?> Function(UserIdFirestore? arg)? build,
    Future<void> Function()? onRefresh,
    Future<void> Function()? onRefreshWithCentauriPointsNumber,
  })  : _build = build ?? ((_) async => null),
        _onRefresh = onRefresh ?? (() async {}),
        _onRefreshWithCentauriPointsNumber =
            onRefreshWithCentauriPointsNumber ?? (() async {});

  @override
  Future<int?> build(UserIdFirestore? arg) => _build(arg);

  @override
  Future<void> refresh() => _onRefresh();

  @override
  Future<void> refreshWithCentauriPointsNumber(int centauriPoints) =>
      _onRefreshWithCentauriPointsNumber();
}

List<Override> mockUserCentauriPointsViewModelCentauriOverride({
  required int centauriPoints,
}) {
  return [
    userCentauriPointsViewModelProvider.overrideWith(
      () => MockUserAvatarCentauriPointsViewModel(
        build: (userUID) async => centauriPoints,
      ),
    ),
  ];
}

final mockUserCentauriPointsViewModelZeroCentauriOverride =
    mockUserCentauriPointsViewModelCentauriOverride(centauriPoints: 0);