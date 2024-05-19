import "package:collection/collection.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/ranking/ranking_details.dart";
import "package:proxima/models/ui/ranking/ranking_element_details.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

/// Provides a refreshable async list of users that are sorted by
/// descending score of centauri points (called their rank).
/// Built for the ranking page to display a leaderboard of
/// all the users in the application.
class UsersRankingViewModel extends AutoDisposeAsyncNotifier<RankingDetails> {
  /// Maximum number of users displayed in the leaderboard
  static const _rankingLimit = 50;

  UsersRankingViewModel();

  @override
  Future<RankingDetails> build() async {
    final userRepository = ref.watch(userRepositoryServiceProvider);
    final user = ref.watch(validLoggedInUserIdProvider);

    // Retrieve the top users from the database
    final topUsersFromDb = await userRepository.getTopUsers(_rankingLimit);

    // Map from users to `RankingElementDetails`
    final topUsers = topUsersFromDb.mapIndexed((i, user) {
      final userData = user.data;
      final userRank = i + 1;

      final userRankingDetails = RankingElementDetails(
        userDisplayName: userData.displayName,
        userUserName: userData.username,
        centauriPoints: userData.centauriPoints,
        userRank: userRank,
      );

      return userRankingDetails;
    }).toList();

    // Retrieve the current user ranking
    final currentUser = await userRepository.getUser(user);
    final currentUserData = currentUser.data;

    // If the current user is in the leaderboard, also provide its rank
    final currentUserRank = topUsers.firstWhereOrNull(
      (ranking) => ranking.userUserName == currentUserData.username,
    );

    final currentUserRankingDetails = RankingElementDetails(
      userDisplayName: currentUserData.displayName,
      userUserName: currentUserData.username,
      centauriPoints: currentUserData.centauriPoints,
      userRank: currentUserRank?.userRank,
    );

    // Combine current user's rank with top users
    final state = RankingDetails(
      rankElementDetailsList: topUsers,
      userRankElementDetails: currentUserRankingDetails,
    );

    return state;
  }

  /// Refresh the list of user rankings
  /// This will put the state of the viewmodel to loading, fetch the posts
  /// and update the state accordingly
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final usersRankingViewModelProvider =
    AutoDisposeAsyncNotifierProvider<UsersRankingViewModel, RankingDetails>(
  () => UsersRankingViewModel(),
);
