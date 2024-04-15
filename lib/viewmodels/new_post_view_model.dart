import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/ui/new_post_state.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

class NewPostViewModel extends AutoDisposeAsyncNotifier<NewPostState> {
  static const _titleError = "Please enter a title";
  static const _bodyError = "Please enter a body";

  @override
  Future<NewPostState> build() async {
    return NewPostState(
      titleError: null,
      descriptionError: null,
      posted: false,
    );
  }

  /// Validates that the title and description are not empty.
  /// If either is empty, the state is updated with the appropriate error message.
  bool validate(String title, String description) {
    if (title.isEmpty || description.isEmpty) {
      state = AsyncData(
        NewPostState(
          titleError: title.isEmpty ? _titleError : null,
          descriptionError: description.isEmpty ? _bodyError : null,
          posted: false,
        ),
      );

      return false;
    }

    return true;
  }

  /// Verifies that the title and description are not empty, then adds a new post to the database.
  /// If the user is not logged in, an exception is thrown.
  /// If the title or description is empty, the state is updated with the appropriate error message.
  /// If the post is successfully added, the state is updated with the posted flag set to true.
  Future<void> addPost(String title, String description) async {
    state = const AsyncLoading();

    final currentUser = ref.read(uidProvider);
    if (currentUser == null) {
      throw Exception("User must be logged in before creating a post");
    }

    if (!validate(title, description)) {
      return;
    }

    final currPosition =
        await ref.read(geoLocationServiceProvider).getCurrentPosition();
    final postRepository = ref.read(postRepositoryProvider);

    final post = PostData(
      ownerId: currentUser,
      title: title,
      description: description,
      publicationTime: Timestamp.now(),
      voteScore: 0,
    );

    await postRepository.addPost(post, currPosition);

    state = AsyncData(
      NewPostState(
        titleError: null,
        descriptionError: null,
        posted: true,
      ),
    );
  }
}

final newPostStateProvider =
    AsyncNotifierProvider.autoDispose<NewPostViewModel, NewPostState>(
  () => NewPostViewModel(),
);
