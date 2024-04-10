import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/login_user.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";

Future<void> addPost(
  String title,
  String description,
  GeoLocationService geoLocationService,
  LoginUser? user,
  PostRepositoryService postRepositoryService,
) async {
  if (title.isEmpty || description.isEmpty) {
    throw const FormatException("Title and description must not be empty");
  }

  final GeoPoint currPosition = await geoLocationService.getCurrentPosition();

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

  await postRepositoryService.addPost(post, currPosition);
}
