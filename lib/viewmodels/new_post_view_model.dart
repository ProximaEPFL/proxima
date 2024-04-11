import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

class NewPostState {
  final String? titleError;
  final String? descriptionError;
  final bool posted;

  NewPostState({
    required this.titleError,
    required this.descriptionError,
    required this.posted,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NewPostState &&
        other.titleError == titleError &&
        other.descriptionError == descriptionError &&
        other.posted == posted;
  }

  @override
  int get hashCode {
    return Object.hash(titleError, descriptionError, posted);
  }
}

class NewPostViewModel extends AsyncNotifier<NewPostState> {
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

  Future<void> addPost(String title, String description) async {
    state = const AsyncLoading();

    final currentUser = ref.read(uidProvider);
    if (currentUser == null) {
      throw Exception("User must be logged in before creating a post");
    }

    if(!validate(title, description)) {
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
    AsyncNotifierProvider<NewPostViewModel, NewPostState>(
  () => NewPostViewModel(),
);
