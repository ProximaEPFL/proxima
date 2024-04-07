import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";

const kmPostRadius = 0.1;

// This provider is used to store the list of posts that are displayed in the home feed.
final postList = Provider<List<PostOverview>>((ref) {
  return List.empty();
});

/// This provider is used to fetch the list of posts that are displayed in the home feed.
/// It fetches the posts from the database and returns a list of [PostOverview] objects to be displayed.
final postProvider = FutureProvider<List<PostOverview>>((ref) async {
  final geoLocationService = ref.watch(geoLocationServiceProvider);
  final postRepository = ref.watch(postRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  final position = await geoLocationService.getCurrentPosition();

  final postsFirestore =
      await postRepository.getNearPosts(position, kmPostRadius);

  final postOwnersId = postsFirestore.map((post) => post.data.ownerId).toSet();

  final postOwners = await Future.wait(
    postOwnersId.map((userId) => userRepository.getUser(userId)),
  );

  final posts = postsFirestore.map((post) {
    final owner = postOwners.firstWhere(
      (user) => user.uid == post.data.ownerId,
      orElse: () => throw Exception("Owner not found"),
    );

    return PostOverview(
      title: post.data.title,
      description: post.data.description,
      votes: post.data.voteScore,
      posterUsername: owner.data.username,
      commentNumber:
          0, // TODO: Update appropriately when comments are implemented
    );
  }).toList();

  return posts;
});
