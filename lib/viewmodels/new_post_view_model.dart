import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/login_user.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";

Future<void> addPost(String title, String description, WidgetRef ref) async {
  if (title.isEmpty || description.isEmpty) {
    throw const FormatException("Title and description must not be empty");
  }

  final GeoPoint currPosition =
      await ref.read(geoLocationServiceProvider).getCurrentPosition();
  final LoginUser? user = ref.read(userProvider).value;

  if (user == null) {
    throw Exception("User must be logged in before creating a post");
  }

  final PostData post = PostData(
    ownerId: UserIdFirestore(value: user.id),
    title: title,
    description: description,
    publicationTime: Timestamp.now(),
    voteScore: 0,
  );

  await ref.read(postRepositoryProvider).addPost(post, currPosition);
}
